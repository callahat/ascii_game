class Game::QuestsController < ApplicationController
  before_filter :setup_pc_vars
  before_filter :setup_quest
  before_filter :verify_quest_log, :only => [:do_complete, :do_reward]

  layout 'main'

  def show
    ( @log_quest && @log_quest.completed && @log_quest.rewarded ?
      @pc.current_event.update_attribute(:completed, EVENT_COMPLETED) :
      @pc.current_event.update_attribute(:completed, EVENT_FAILED)     )
  end
  
  def do_join
    _res, @message = LogQuest.join_quest(@pc, @quest.id)
    render :file => 'game/complete', :layout => true
  end
  
  def do_decline
    @message = "You decline the quest. Perhaps it is too much for you."
    render :file => 'game/complete', :layout => true
  end
  
  def do_complete
    if @log_quest.complete_quest
      redirect_to do_reward_game_quests_path
    else
      redirect_to game_quests_path
    end
  end
  
  def do_reward
    res, msg = @log_quest.collect_reward
    flash[:notice] = msg
    if res
      @pc.current_event.update_attribute(:completed, EVENT_COMPLETED)
    end
    redirect_to game_quests_path
  end

  protected

  def setup_quest
    redirect_to game_feature_path unless @pc.current_event(->{includes(:event)}) && @pc.current_event.event.class == EventQuest
    @event = @pc.current_event.event(->{includes(:quest)})
    @quest = @event.quest
    if @quest.quest_id && 
        DoneQuest.find_by(quest_id: @quest.quest_id, player_character_id: @pc.id ).nil?
      flash[:notice] = "Nothing happens"
       @pc.current_event.destroy
      redirect_to main_game_path
    else
      @log_quest = @pc.log_quests.find_by(quest_id: @quest.id)
    end
  end
  
  def verify_quest_log
    redirect_to game_quests_path unless @log_quest
  end
end
