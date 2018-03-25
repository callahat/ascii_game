class Game::BattleController < ApplicationController
  #before_filter :authenticate
  before_filter :setup_pc_vars

  layout 'main'

  def fight_pc
    @enemy_pc = @pc.current_event.event.player_character
    result, msg = Battle.new_pc_battle(@pc, @enemy_pc)

    pre_battle_director(result, msg)
  end

  def fight_npc
    @npc = @pc.current_event.event.npc
    result, msg = Battle.new_npc_battle(@pc, @npc)

    pre_battle_director(result, msg)
  end

  def fight_king
    @kingdom = @pc.present_kingdom
    result, msg = Battle.new_king_battle(@pc, @kingdom)

    pre_battle_director(result, msg)
  end

  def battle
    @battle = @pc.battle

    if @battle.nil?
      redirect_to game_main_path
    elsif session[:regicide] && session[:keep_fighting].nil?
      session[:keep_fighting] = true
      @pc.present_kingdom.change_king(nil)
      redirect_to :action => 'regicide'
    elsif @booty = @battle.victory
      @message = "The enemy host has been defeated!<br/>Found " + @booty[:gold].to_s + " gold."
      if @pc.in_kingdom
        @message += " Taxman takes " + @booty[:tax].to_s + " of it."
      end
      @pc.current_event.update_attribute(:completed, EVENT_COMPLETED) if @pc.current_event
      @battle.clear_battle
      render 'game/complete'
    elsif @pc.health.HP <= 0
      @message = "You have been killed."
      @battle.clear_battle
      render 'game/complete'
    else #fight on!
      @healing_spells = []
      @attack_spells = []
      if @pc.c_class.healing_spells
        healing_list = HealingSpell.where(['min_level < ?', @pc.level])
        @healing_spells = healing_list.collect() {|s| [s.name + ' (MP:' + s.mp_cost.to_s + ')' , s.id ] }
      end
      if @pc.c_class.attack_spells
        attack_list = AttackSpell.where(['min_level < ?', @pc.level])
        @attack_spells = attack_list.collect() {|s| splash = ( s.splash ? ' (splash)' : '' )
                                  [ s.name + ' (MP:' + s.mp_cost.to_s + ' HP:' + s.hp_cost.to_s + ')' + splash , s.id]}
      end
    end
  end

  def fight
    @battle = @pc.battle
    
    @bg = @battle.groups.find_by_name(params[:commit]) if params[:commit] && params[:commit] != ""
    
    session[:attack] = params[:attack]
    session[:attack] = (@spell = AttackSpell.find(params[:attack])).id if params[:commit] !~ /Heal/ && params[:attack] && params[:attack] != ""
    if params[:commit] =~ /Heal/
      @spell = HealingSpell.find(params[:heal])
      session[:heal] = @spell.id
      @bg = @pc 
    end

    @battle.report = {}
    @battle.for_this_round(@pc, @bg, @spell)

    session[:regicide] = @battle.regicide

    flash[:battle_report] = @battle.report

    redirect_to :action => 'battle'
  end

  def run_away
    @battle = @pc.battle

    if @battle.run_away(75)
      @pc.current_event.update_attribute(:completed, EVENT_FAILED) if @pc.current_event
      session[:regicide] = nil
      session[:keep_fighting] = nil
      @message = 'You ran away.'
      render 'game/complete'
    else
      @message = 'could not run away'
      @battle.for_this_round(@pc, nil)
      flash[:notice] = 'Could not run away'
      flash[:battle_report] = @battle.report
      redirect_to :action => 'battle'
    end
  end

  def regicide
    if session[:regicide]
      session[:completed] = true
      @kingdom = Kingdom.find session[:regicide]
    else
      redirect_to feature_game_path
    end
  end

  def fate_of_throne
    if session[:regicide]
      @kingdom = Kingdom.find session[:regicide]
      case params[:q]
        when 'abandon'
          @pc.current_event.update_attribute(:completed, EVENT_COMPLETED) if @pc.current_event

          @kingdom.player_character_id = nil
          @kingdom.save

          @pc.battle.clear_battle

          @message = 'You leave a kingdom without a king.'
          render 'game/complete'
        when 'keep_fighting'
          @kingdom.player_character_id = @pc.id
          @kingdom.save

          redirect_to action: :battle
        else #claim
          @pc.current_event.update_attribute(:completed, EVENT_COMPLETED) if @pc.current_event
          @kingdom.player_character_id = @pc.id
          @kingdom.save
          @pc.battle.clear_battle

          @message = 'Long live the new king.'
          render 'game/complete'
      end
    else
      redirect_to :action => 'battle'
    end

    session[:regicide] = nil
    session[:keep_fighting] = nil
  end
protected
  #In the future, this may not be needed if events leading to battles setup the battle stuff themselves and
  #redirect to the battle action. But for now, here it is.
  def pre_battle_director(result, msg, comp=nil)
    if result
      redirect_to :action => 'battle'
    else
      @message = msg
      session[:completed] = comp
      render 'game/complete'
    end
  end
end
