class EventQuest < Event
  belongs_to :quest, :foreign_key => 'thing_id'

  #validates_presence_of :thing_id

  def make_happen(pc)
    lq = pc.log_quests.find(:first, :conditions => ['quest_id = ?', thing_id])
    return {:controller => 'game/quests', :action => 'do_complete'}, EVENT_COMPLETED, "" if  lq && lq.reqs_met
    return {:controller => 'game/quests', :action => 'index'}, EVENT_INPROGRESS, ""
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
