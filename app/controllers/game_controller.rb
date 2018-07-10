class GameController < ApplicationController
  before_filter :setup_pc_vars

  layout 'main'

  def main
    flash[:notice] = flash[:notice]
    
    #this is the main game controller. Find out where the person is,
    if @pc.present_kingdom
      @where = @pc.present_level
    elsif @pc.present_world
      @where = [@pc.present_world,
                @pc.bigx,
                @pc.bigy]
    else
      flash[:notice] = 'You find yourself floating in empty space. There is nothing of interest anywhere.'
    end
  end

  def leave_kingdom
    if @pc.present_level && @pc.present_level.level == 0
      PlayerCharacter.transaction do
        @pc.lock!
        @pc.in_kingdom = nil
        @pc.kingdom_level = nil
        @pc.save!
      end
      @message = "Left the kingdom"
    end
    
    redirect_to main_game_path
  end

  #moving in the world, by just walking. no need for an event
  def world_move
    PlayerCharacter.transaction do
      @pc.lock!
      if params[:id] == 'north' && WorldMap.exists?(:bigxpos => @pc[:bigx], :bigypos => @pc[:bigy] -1)
        flash[:notice] = "Moved North"
        @pc[:bigy] -= 1
      elsif params[:id] == 'south' && WorldMap.exists?(:bigxpos => @pc[:bigx], :bigypos => @pc[:bigy] +1)
        flash[:notice] = "Moved South"
        @pc[:bigy] += 1
      elsif params[:id] == 'west' && WorldMap.exists?(:bigxpos => @pc[:bigx] - 1, :bigypos => @pc[:bigy])
        flash[:notice] = "Moved West"
        @pc[:bigx] -= 1
      elsif params[:id] == 'east' && WorldMap.exists?(:bigxpos => @pc[:bigx] + 1,:bigypos => @pc[:bigy])
        flash[:notice] = "Moved East"
        @pc[:bigx] += 1
      else
        flash[:notice] = "Unknown/invalid direction"
      end
      @pc.save!
    end
    redirect_to main_game_path
  end

  #deal with the feature, set up the session feature_event chain
  def feature
    flash[:notice] = flash[:notice]

    if @pc.reload && @pc.battle
      redirect_to :controller => 'game/battle', :action => 'battle'
    else #check for current event
      if session[:ev_choice_ids] && (@events = Event.where(id: session[:ev_choice_ids]))#.includes(:thing))
        render :file => 'game/choose', :layout => true
      elsif @current_event = @pc.current_event
        if @current_event.completed == EVENT_INPROGRESS #already have an event in progress
          exec_event(@current_event)
        elsif @current_event.completed == EVENT_FAILED
          @current_event.destroy
          redirect_to main_game_path
        else #skipped or completed, get the next event for the feature
          #p "Skipping: event completed code:" + @current_event.completed.to_s
          next_event_helper(@current_event)
        end
      elsif params[:id]
        #start new current event
        Rails.logger.info "Starting" + params[:id].to_s
        @current_event = CurrentEvent.make_new(@pc, params[:id])
        if TxWrapper.take(@pc, :turns, @current_event.location.feature.action_cost)
          next_event_helper(@current_event)
        else
          @current_event.destroy
          flash[:notice] = 'Too tired for that, out of turns.'
          redirect_to main_game_path
        end
      else #no current event and no feature id
        redirect_to main_game_path
      end
    end
  end

  def do_choose
    Rails.logger.info "In do_choose"
    @current_event = @pc.current_event
    if Event.exists?(:id => params[:id]) && session[:ev_choice_ids].index(params[:id].to_i)

      Rails.logger.info "exisst, going to execute"
      @current_event.update_attribute(:event_id, params[:id])
      session[:ev_choice_ids] = nil
      exec_event(@current_event)
    elsif params[:id]
      Rails.logger.info "invalid"
      flash[:notice] = "Invalid choice"
      @events = Event.find(session[:ev_choice_ids])
      render :file => 'game/choose', :layout => true
    elsif @current_event #id is null, player didnt choose any event, or they attempted a hack
      Rails.logger.info "player didnt choose as id is null"
      @current_event.update_attribute(:completed, EVENT_SKIPPED)
      session[:ev_choice_ids] = nil
      flash[:notice] = 'You slink on by without anything interesting happening.'
      redirect_to complete_game_path
    else
      Rails.logger.warn "!!! current event expected but not found for pc:#{@pc.id} chose event id:#{params[:id]}"
      session[:ev_choice_ids] = nil
      flash[:notice] = 'You feel like something should have happened.'
      redirect_to complete_game_path
    end
  end

  def wave_at_pc
    @other_pc = @pc.current_event.event.player_character
    Illness.spread(@pc, @other_pc, SpecialCode.get_code('trans_method','air') )
    Illness.spread(@other_pc, @pc, SpecialCode.get_code('trans_method','air') )
  end

  def make_camp
    if @pc.current_event
      flash[:notice] = "Cannot rest while in midst of action!"
    elsif TxWrapper.take(@pc, :turns, 1)
      Health.transaction do
        @pc.health.lock!
        @hp_gain = MiscMath.min((@pc.health.base_HP * (rand() /10.0 + 0.07)).to_i, @pc.health.base_HP - @pc.health.HP)
        @mp_gain = MiscMath.min((@pc.health.base_MP * (rand() /10.0 + 0.03)).to_i, @pc.health.base_MP - @pc.health.MP)
        @pc.health.HP += @hp_gain
        @pc.health.MP += @mp_gain
      
        flash[:notice] = 'Rested'
        if @pc.health.base_HP == @pc.health.HP
          flash[:notice] += ', and rose from the grave' if @pc.health.wellness == SpecialCode.get_code('wellness','dead')
          if @pc.illnesses.size == 0
            @pc.health.wellness = SpecialCode.get_code('wellness','alive')
          else
            @pc.health.wellness = SpecialCode.get_code('wellness','diseased')
          end
        end
        @pc.health.save!
      end
      flash[:notice] += ', gained ' + @hp_gain.to_s + ' HP' if @hp_gain > 0
      flash[:notice] += ', gained ' + @mp_gain.to_s + ' MP' if @mp_gain > 0
    else
      flash[:notice] = "Too tired to make camp"
    end
    @pc.reload
    redirect_to main_game_path
  end
  
  def complete
    flash[:notice] = flash[:notice]
    @current_event = @pc.current_event(->{includes(:event,:location)})
    if @current_event
      @next,@events = @current_event.complete
    else
      print "No current event found for PC #{@pc.name} #{@pc.current_event}!\n"
    end
    @pc.reload
    
    if @next.nil?
      @current_event.destroy if @current_event
      redirect_to main_game_path
    else
      redirect_to feature_game_path
    end
  end
  
  def spawn_kingdom
    @kingdom = Kingdom.new
  end
  
  def do_spawn
    redirect_to(:action=>'feature') && return \
      unless @pc.current_event && @pc.current_event.event.class == EventSpawnKingdom
    @wm = @pc.current_event.location
    
    @kingdom, @msg = Kingdom.spawn_new(@pc, params[:kingdom][:name], @wm)
    if @kingdom
      render :controller => 'game', :action => 'spawn_kingdom'
    else
      flash[:notice] = @msg
      session[:completed] = true
      redirect_to complete_game_path
    end
  end
  
protected
  #should these live in the event class?
  def exec_event(ce)
    if ce.event
      @direction, @completed, @message = ce.event.happens(@pc)
      ce.update_attribute(:completed, @completed)
      @pc.reload
    else
      Rails.logger.warn "!!! No event found for current event; #{ce.inspect}"
      ce.update_attribute(:completed, @completed)
      @pc.reload
    end

    if @direction
      flash[:notice] = @message
      redirect_to @direction
    else
      render :file => 'game/complete', :layout => true
    end
  end
  
  def next_event_helper(ce)
    @next, @it = ce.next_event
    
    if @next.nil?
      flash[:notice] = "Nothing happens"
      @current_event.destroy
      redirect_to main_game_path
    elsif @it.class == Array
      ce.update_attributes(:priority => @next)
      @events = @it
      session[:ev_choice_ids] = @events.map(&:id) #simplify whats a valid choice or not
      render :file => 'game/choose', :layout => true
    else #must be an event
      ce.update_attributes(:event_id => @it.id, :priority => @next)
      exec_event(ce)
    end
  end
end
