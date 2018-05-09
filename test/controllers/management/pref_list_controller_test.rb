require 'test_helper'

class Management::PrefListControllerTest < ActionController::TestCase
	def setup
		sign_in Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:kingdom] = Kingdom.find_by_name("HealthyTestKingdom")
	end
	
	test "pref list controllers" do
		[ { :thing_class => Creature,
				:pref_list_class => PrefListCreature,
				:name_on_list => "Wimp Monster",
				:name_not_list => "Tough Monster" },
			{ :thing_class => EventCreature,
				:pref_list_class => PrefListEvent,
				:name_on_list => "Weak Monster encounter",
				:name_not_list => "Tough Monster encounter" },
			{ :thing_class => Feature,
				:pref_list_class => PrefListFeature,
				:name_on_list => "Creature Feature One",
				:name_not_list => "Feature Nothing" } ].each do |type|
			#p type[:pref_list_class]
			@pref_thing = type[:thing_class].find_by_name(type[:name_on_list])
			@other_thing = type[:thing_class].find_by_name(type[:name_not_list])
			session[:pref_list_type] = type[:pref_list_class]
			
			get 'index', {}
			assert session[:kingbit], "The king bit is false"
			assert_template 'index'
			assert_not_nil assigns(:all_things)
			assert_not_nil assigns(:pref_list)
			
			#add already added
			assert_difference 'session[:pref_list_type].count', +0 do
				post 'add_to_list', {:id => @pref_thing.id}
			end
			
			#broken for now - need to remove the match all thing
			#
			##add new with a get
			#assert_difference 'session[:pref_list_type].count', +0 do
			#	get 'add_to_list', {:id => @other_thing.id}
			#end
			#assert_redirected_to :controller => 'management/pref_list', :action => 'index'
			
			#add new
			assert_difference 'session[:pref_list_type].count', +1 do
				post 'add_to_list', {:id => @other_thing.id}
			end
			assert_redirected_to :controller => 'management/pref_list', :action => 'index'
			
			#drop old
			assert_difference 'type[:pref_list_class].count', -1 do
				post 'drop_from_list', {:id => @pref_thing.id}
			end
			
			#drop old again
			assert_difference 'type[:pref_list_class].count', +0 do
				post 'drop_from_list', {:id => @pref_thing.id}
			end
		end
	end
end
