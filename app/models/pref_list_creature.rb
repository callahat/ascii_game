class PrefListCreature < PrefList
	belongs_to :creature, :foreign_key => 'thing_id', :class_name => 'Creature'
	belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Creature'
end