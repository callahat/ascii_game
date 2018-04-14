require 'test_helper'

class Management::EventsControllerTest < ActionController::TestCase
	def setup
		sign_in players(:test_player_one)
		session[:player_character] = player_characters(:test_pc_one)
		session[:kingdom] = kingdoms(:kingdom_one)
		
		@e_armed = Event.find_by_name("Weak Monster encounter")
		@e = Event.find_by_name("Unarmed Text Event")
		@e_hash = {:name => "New Quest Event Name", :kind => "EventText", :text => "Yay quest (just text)",
								:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited') }
	end
	
	test "mgmt event controller index" do
		get 'index', {}
		assert_response :success
		assert_not_nil assigns(:events)
	end
	
	test "mgmt event controller show" do
		get 'show', {:id => @e.id}
		assert_response :success
		assert_not_nil assigns(:event)
	end
	
	test "mgmt event controller new all event types" do
		["EventCreature","EventItem","EventMoveLocal",
		 "EventMoveRelative","EventQuest","EventText"].each{|k|
			#p k
			get 'new', {:event => {:kind => k}}
			assert_response :success
			assert_match Regexp.new(k), @response.body, Regexp.new(k)
			assert_match /value="#{k}"/, @response.body
		}
	end
	
	test "mgmt event controller new and create" do
		get 'new', {}
		assert_response :success
		
		post 'create', {:event => {}}
		assert_response :success
		assert_template 'new'
		
		get 'new', {:event => {:kind => @e_hash[:kind]}}
		assert_response :success
		assert_template 'new'
		
		assert_difference 'Event.count', +1 do
			post 'create', { :event => @e_hash }
			assert_response :redirect, @response.body
			assert_redirected_to :controller => 'management/events', :action => 'index'
		end
	end
	
	test "mgmt event controller edit and update" do
		get 'edit', {:id => @e.id}
		assert_response :success
		
		e_attrs = @e.attributes
		e_attrs[:text] = "Updated text"
		post 'update', {:id => @e.id, :event => e_attrs}
		assert_response :redirect
		assert_redirected_to :controller => 'management/events', :action => 'index'
		assert flash[:notice] =~ /updated/
	end
	
	test "mgmt event controller destroy" do
		assert_no_difference 'Event.count' do
			post 'destroy', {:id => @e_armed.id}
			assert_redirected_to :controller => 'management/events', :action => 'index'
			assert flash[:notice] =~ /being used/
		end
		
		assert_difference 'Event.count', -1 do
			post 'destroy', {:id => @e.id}
			assert_redirected_to :controller => 'management/events', :action => 'index'
			assert flash[:notice] =~ /sucessfully destroyed/
		end
	end
	
	test "mgmt event controller arm" do
		post 'arm', {:id => @e_armed.id}
		assert_redirected_to :controller => 'management/events', :action => 'index'
		assert flash[:notice] =~ /being used/

		post 'arm', {:id => @e.id}
		assert_redirected_to :controller => 'management/events', :action => 'index'
		assert flash[:notice] =~ /Added to preference/
		assert flash[:notice] =~ /sucessfully armed/
		
		post 'arm', {:id => @e.id}
		assert_redirected_to :controller => 'management/events', :action => 'index'
		assert flash[:notice] =~ /being used/, flash[:notice]
	end
	
	test "mgmt event controller pref list redirector" do
		get 'pref_lists', {}
		assert_redirected_to :controller => 'management/pref_list'
		assert session[:pref_list_type] == PrefListEvent
	end
end
