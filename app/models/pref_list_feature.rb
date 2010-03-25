class PrefListFeature < PrefList
	belongs_to :feature, :foreign_key => 'thing_id', :class_name => 'Feature'
	belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Feature'
end