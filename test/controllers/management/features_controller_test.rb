require 'test_helper'

class Management::FeaturesControllerTest < ActionController::TestCase
	def setup
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:kingdom] = Kingdom.find_by_name("HealthyTestKingdom")
		
		@f_image = Image.find_by_name("Feature image")
		@f_armed = Feature.find_by_name("Creature Feature One")
		@f = Feature.find_by_name("Unarmed Feature")
		@f_hash = {:name => "New Feature Name", :action_cost => 1, :world_feature => 0,
								:kingdom_id => session[:kingdom][:id], :player_id => session[:player][:id]}
		@i_hash = {:image_text => "###\n###\n#H#", :image_type => SpecialCode.get_code('image_type','kingdom'),
							:player_id => session[:player][:id], :kingdom_id => session[:kingdom][:id]}
		@e = Event.find_by_name("Weak Monster encounter")
		@fe_hash = {:event_id => @e.id, :chance => 100, :priority => 1, :feature_id => @f.id}
	end
	
	test "mgmt feature controller index" do
		get 'index', {}, session.to_hash
		assert_response :success
		assert_not_nil assigns(:features)
	end
	
	test "mgmt feature controller show" do
		get 'show', {:id => @f.id}, session.to_hash
		assert_response :success
		assert_not_nil assigns(:feature)
	end
	
	test "mgmt feature controller new and create" do
		get 'new', {}, session.to_hash
		assert_response :success
		
		post 'create', {:feature => {}, :image => {:image_text => ""}}, session.to_hash
		assert_response :success
		assert_template 'new'
		
		assert_difference 'Feature.count', +1 do
			post 'create', { :feature => @f_hash, :image => @i_hash }, session.to_hash
			assert_response :redirect
			assert_redirected_to :controller => 'management/features', :action => 'index'
		end
		@new_f_image = Feature.find_by_name("New Feature Name").image
		assert @new_f_image.image_text.split("\n").size == 10
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
	end
	
	test "mgmt feature controller edit and update" do
		get 'edit', {:id => @f.id}, session.to_hash
		assert_response :success
		
		f_attrs = @f.attributes
		f_attrs[:num_occupants] = 100
		post 'update', {:id => @f.id, :feature => f_attrs, :image => @f.image.attributes}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'management/features', :action => 'show', :id => @f.id
		assert flash[:notice] =~ /updated/
		
		@new_f_image = Feature.find(@f.id).image
		assert @new_f_image.image_text.split("\n").size == 10
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
	end
	
	test "mgmt feature controller destroy" do
		assert_no_difference 'Feature.count' do
			post 'destroy', {:id => @f_armed.id}, session.to_hash
			assert_redirected_to :controller => 'management/features', :action => 'index'
			assert flash[:notice] =~ /being used/
		end
		
		assert_difference 'Feature.count', -1 do
			post 'destroy', {:id => @f.id}, session.to_hash
			assert_redirected_to :controller => 'management/features', :action => 'index'
			assert flash[:notice] =~ /destroyed/
		end
	end
	
	test "mgmt feature controller arm" do
		post 'arm', {:id => @f_armed.id}, session.to_hash
		assert_redirected_to :controller => 'management/features', :action => 'index'
		assert flash[:notice] =~ /not be added/, flash[:notice]

		post 'arm', {:id => @f.id}, session.to_hash
		assert_redirected_to :controller => 'management/features', :action => 'index'
		assert flash[:notice] =~ /Added to preference/
		assert flash[:notice] =~ /sucessfully armed/
		
		post 'arm', {:id => @f.id}, session.to_hash
		assert_redirected_to :controller => 'management/features', :action => 'index'
		assert flash[:notice] =~ /not be added/, flash[:notice]
	end
	
	test "mgmt feature controller pref list redirector" do
		get 'pref_lists', {}, session.to_hash
		assert_redirected_to :controller => 'management/pref_list'
		assert session[:pref_list_type] == PrefListFeature
	end
	
	test "mgmt feature controller new and create feature events" do
		get 'new_feature_event', {:id => @f.id}, session.to_hash
		assert_response :success
		
		post 'create_feature_event', {:id => @f.id, :feature_event => {:feature_id => @f.id, :event_id => @e.id} }, session.to_hash
		assert_response :success
		assert_template 'new_feature_event'
		
		assert_difference '@f.feature_events.count', +1 do
			post 'create_feature_event', {:id => @f.id, :feature_event => @fe_hash }, session.to_hash
			assert_response :redirect
			assert_redirected_to :controller => 'management/features', :action => 'show', :id => @f.id
		end
	end
	
	test "mgmt feature controller edit and update feature events" do
		@feid = @f.feature_events.first
		get 'edit_feature_event', {:id => @feid}, session.to_hash
		assert_response :success
		
		@fe_hash[:chance] = -33
		post 'update_feature_event', {:id => @feid, :feature_event => @fe_hash }, session.to_hash
		assert_response :success
		assert_template 'edit_feature_event'
		
		@fe_hash[:chance] = 50
		assert_difference '@f.feature_events.count', +0 do
			post 'update_feature_event', {:id => @feid, :feature_event => @fe_hash }, session.to_hash
			assert_response :redirect
			assert_redirected_to :controller => 'management/features', :action => 'show', :id => @f.id
		end
	end
	
	test "mgmt feature controller destroy feature events" do
		assert_no_difference '@f_armed.feature_events.count' do
			post 'destroy_feature_event', {:id => @f_armed.feature_events.first.id}, session.to_hash
			assert_redirected_to :controller => 'management/features', :action => 'index'
			assert flash[:notice] =~ /being used/
		end
		
		assert_difference '@f.feature_events.count', -1 do
			post 'destroy_feature_event', {:id => @f.feature_events.first.id}, session.to_hash
			assert_redirected_to :controller => 'management/features', :action => 'show', :id => @f.id
			assert flash[:notice] =~ /destroyed/
			@f.feature_events.reload
		end
	end
end
