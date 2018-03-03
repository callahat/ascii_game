class PrefListCreature < PrefList
  belongs_to :creature, :foreign_key => 'thing_id', :class_name => 'Creature'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Creature'
  
  def self.eligible_list(pid, kid)
    Creature.where(armed: true).where(['public = true or player_id = ? or kingdom_id = ?', pid, kid])
                  .order(:name)
  end
  
  def self.current_list(k)
    k.pref_list_creatures
  end
end
