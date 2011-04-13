class PrefListEvent < PrefList
  belongs_to :event, :foreign_key => 'thing_id', :class_name => 'Event'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Event'
  
  def self.eligible_list(pid, kid)
    Event.find(:all,
              :conditions => ['armed and (player_id = ? or kingdom_id = ?)', pid, kid],
              :order => 'name')
  end
  
  def self.current_list(k)
    k.pref_list_events
  end
end
