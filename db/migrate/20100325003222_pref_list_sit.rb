class PrefListSit < ActiveRecord::Migration
	def self.up
		add_column :pref_lists, :kind, :string, :limit => 20
		add_index  :pref_lists, ["kind"], :name => "kind"
		
		PrefList.all.each{|pf|
			case pf.pref_list_type
				when SpecialCode.get_code('pref_list_type','creatures')
					pf.update_attribute(:kind, 'PrefListCreature')
				when SpecialCode.get_code('pref_list_type','events')
					pf.update_attribute(:kind, 'PrefListEvent')
				when SpecialCode.get_code('pref_list_type','features')
					pf.update_attribute(:kind, 'PrefListFeature')
			end
		}
		remove_column :pref_lists, :pref_list_type
	end

	def self.down
		add_column :pref_lists, :pref_list_type, :integer
		
		PrefList.all.each{|pf|
			case pf.class.name
				when 'PrefListCreature'
					pf.update_attribute(:pref_list_type, SpecialCode.get_code('pref_list_type','creatures'))
				when 'PrefListEvent'
					pf.update_attribute(:pref_list_type, SpecialCode.get_code('pref_list_type','events'))
				when 'PrefListFeature'
					pf.update_attribute(:pref_list_type, SpecialCode.get_code('pref_list_type','features'))
			end
		}
		remove_column :pref_lists, :kind
	end
end
