class Management::LevelsController < ApplicationController
  include KingdomManagement

  before_filter :setup_level_variable, :only => [:edit, :update]

  def index
    @levels = @kingdom.levels.get_page(params[:page])
  end

  def show
    @level = @kingdom.levels.find(params[:id])
  end

  def new
    @level = Level.new

    @lowest = @kingdom.levels.first.level - 1
    @highest = @kingdom.levels.last.level + 1
  end

  def create
    @level = @kingdom.levels.build(level_params)

    #make sure king can afford
    @cost = (@level.level.abs ** 3) * @level.maxx.to_i * @level.maxy.to_i
    session[:kingdom][:gold] = Kingdom.find(session[:kingdom][:id]).gold

    unless TxWrapper.take(@kingdom, :gold, @cost)
      flash[:notice] = 'It would cost ' + @cost.to_s + ' gold, which the kingdom doesn\'t have.'
      redirect_to new_management_level_path
    else
      if @level.save
        @emtpy_feature = Feature.find_by(name: "Empty", kingdom_id: -1, player_id: -1)
        LevelMap.gen_level_map_squares(@level, @emtpy_feature)
        flash[:notice] = 'Level ' + @level.level.to_s + ' was successfully created.'
        flash[:notice] += '<br/>' + @savecount.to_s + ' map squares out of ' + (@level.maxy * @level.maxx).to_s + ' created.'
        redirect_to management_levels_path
      else
        @lowest = session[:kingdom].levels.first.level - 1
        @highest = session[:kingdom].levels.last.level + 1
        render :action => 'new'
      end
    end
  end

  def edit
    @gold = @kingdom.gold
    @empty_feature = Feature.find_by(name: "Empty", kingdom_id: -1, player_id: -1)
    @features = @kingdom.pref_list_features.includes(feature: [:image,{feature_events: :event}]).collect{|f| f.feature}.unshift(@empty_feature)
  end

  def update
    @gold = @kingdom.gold
    @empty_feature = Feature.find_by(name: "Empty", kingdom_id: -1, player_id: -1)
    calc_cost

    unless TxWrapper.take(@kingdom, :gold, @cost)
      flash[:notice] = 'There is not enough gold in your coffers to pay for the construction.<br/>'
      flash[:notice] += 'Available amount : ' + session[:kingdom][:gold].to_s + ' ; Total build cost : ' + @cost.to_s
      redirect_to edit_management_level_path(:id => @level.id)
    else
      0.upto(@level.maxy-1){|y|
        0.upto(@level.maxx-1){|x|
          @temp = @level.level_maps.where(ypos: y, xpos: x).last

          if params[:map][y.to_s][x.to_s] != "" && (@temp.feature_id.to_i != params[:map][y.to_s][x.to_s].to_i) &&
             (@temp.feature.nil? || !@temp.feature.system_generated )
            #The above is why you should not use special characters in a name to drive certain behavior.
            #This whole management console should be refactored.
            #if this is has storefronts, get rid of the previous store vacancies.
            if @temp.feature
              if @temp.feature.store_front_size.to_i > 0
                @temp.kingdom_empty_shops.each{ |store| store.destroy }
                @temp.feature.feature_events(includes: [:event]).each do |fe|
                  next unless fe.event.class == EventNpc
                  fe.event.npc.update_attribute(:is_hired, false)
                  fe.event.destroy
                  fe.destroy
                end
              end
              TxWrapper.take(@kingdom, :housing_cap, @temp.feature.num_occupants.to_i)
            end

            @temp = LevelMap.create(
                      :level_id => @level.id,
                      :xpos => x,
                      :ypos => y,
                      :feature_id => params[:map][y.to_s][x.to_s])
            Rails.logger.info "Should have created level map with id:#{@temp.id}"
            Rails.logger.info "Errors?#{@temp.errors}"

            if @temp.feature
              TxWrapper.give(@kingdom, :housing_cap, @temp.feature.num_occupants)
              @temp.feature.store_front_size.times{
                @kingdom.kingdom_empty_shops.create(:level_map_id => @temp.id) }
            end
          else
            Rails.logger.warn "User tried overwriting #{@temp.feature ? @temp.feature.name : 'nil feature' } in the kingdom level"
          end
        }
      }
      flash[:notice] = 'Level was successfully updated. Cost was : ' + @cost.to_s
      redirect_to management_level_path(:id => @level.id)
    end
  end

  protected

  def calc_cost
    @cost = 0
    return if params.nil? || params[:map].nil?

    Rails.logger.info "Calculating cost of updated kingdom level, one feature at a time"
    0.upto(@level.maxy-1){|y|
      0.upto(@level.maxx-1){|x|
        old = @level.level_maps.where(ypos: y, xpos: x).last.feature
        new = ( params[:map][y.to_s][x.to_s] && params[:map][y.to_s][x.to_s] != "" ?
                  Feature.find(params[:map][y.to_s][x.to_s]) : nil )
        Rails.logger.info "#{ new ? new.id : 'Nothing' } - #{ old ? old.id : 'Nothing' }"
        Rails.logger.info "#{(new ? new.cost : 0)} - #{(old ? old.cost : 0) / 5} = #{params[:map][y.to_s][x.to_s]}"
        Rails.logger.info "Total cost:" + @cost.to_s
        @cost += ((new ? new.cost : 0) - ( (old ? old.cost : 0) / 5)) if new and (old.nil? or old.id != new.id)
      }
    }
    Rails.logger.info "Total cost:" + @cost.to_s
    return @cost
  end

  def setup_level_variable
    unless @level = @kingdom.levels.where( ['id = ?', params[:id] ] ).last
      redirect_to management_level_path()
      return
    end
  end

  def level_params
    params.require(:level).permit(:maxx, :maxy, :level)
  end
end
