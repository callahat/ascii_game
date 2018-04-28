class EventQuest < Event
  belongs_to :quest, :foreign_key => 'thing_id'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Npc'

  #validates_presence_of :thing_id

  def make_happen(pc)
    lq = pc.log_quests.find_by(quest_id: thing_id)
    return url_helpers.do_complete_game_quests_path, EVENT_COMPLETED, "" if  lq && lq.reqs_met
    return url_helpers.game_quests_path, EVENT_INPROGRESS, ""
  end
  
  def as_option_text(pc=nil)
    name + " (quest event)"
  end
  
  #special text
  def initial_text
    inner_text("initial")
  end
  
  def req_text
    inner_text("requirements")
  end
  
  def reward_text
    inner_text("reward")
  end
protected
  def inner_text(tag)
    text =~ /<#{tag}>(.*)<\/#{tag}>/m
    return $1
  end
end
