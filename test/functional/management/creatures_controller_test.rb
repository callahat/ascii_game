require 'test_helper'

class Management::CreaturesControllerTest < ActionController::TestCase
	def setup
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:kingdom] = Kingdom.find_by_name("HealthyTestKingdom")
		
		@c_armed = Creature.find_by_name("Wimp Monster")
		@c = Creature.find_by_name("Unarmed Monster")
		@c_hash = {:name => "New creature Name", :HP => 60, :gold => 5, :number_alive => -1, :fecundity => 10,
								:kingdom_id => session[:kingdom][:id], :player_id => session[:player][:id]}
		@s_hash = {:dam => 10, :dex => 5, :dfn => 5, :con => 5, :int => 5, :mag => 10, :str => 30}
		@i_hash = {:image_text => "-_o"}
	end
	
	test "mgmt creature controller index" do
		get 'index', {}, session
		assert_response :success
		assert_not_nil assigns(:creatures)
	end
	
	test "mgmt creature controller show" do
		get 'show', {:id => @c.id}, session
		assert_response :success
		assert_not_nil assigns(:creature)
	end
	
	test "mgmt creature controller new and create" do
		get 'new', {}, session
		assert_response :success
		
		post 'create', {:creature => {}, :image => {}, :stat => {}}, session
		assert_response :success
		assert_template 'new'
		
		assert_difference 'Creature.count', +1 do
			post 'create', { :creature => @c_hash, :image => @i_hash, :stat => @s_hash }, session
			assert_response :redirect
			assert_redirected_to :controller => 'management/creatures', :action => 'index'
		end
	end
	
	test "mgmt creature controller edit and update" do
		get 'edit', {:id => @c.id}, session
		assert_response :success
		
		post 'update', {:id => @c.id, :creature => {:gold => nil}, :image => @c.image, :stat => {}}, session
		assert_response :success
		assert_template 'edit'
		
		post 'update', {:id => @c.id, :creature => @c.attributes, :image => @c.image.attributes, :stat => {}}, session
		assert_response :redirect
		assert_redirected_to :controller => 'management/creatures', :action => 'index'
		assert flash[:notice] =~ /updated/
	end
	
	test "mgmt creature controller destroy" do
		assert_no_difference 'Creature.count' do
			post 'destroy', {:id => @c_armed.id}, session
			assert_redirected_to :controller => 'management/creatures', :action => 'index'
			assert flash[:notice] =~ /being used/
		end
		
		assert_difference 'Creature.count', -1 do
			post 'destroy', {:id => @c.id}, session
			assert_redirected_to :controller => 'management/creatures', :action => 'index'
			assert flash[:notice] =~ /Creature destroyed/
		end
	end
	
	test "mgmt creature controller arm" do
		get 'arm_creature', {:id => @c_armed.id}, session
		assert_redirected_to :controller => 'management/creatures', :action => 'index'
		assert flash[:notice] =~ /Could not be/

		get 'arm_creature', {:id => @c.id}, session
		assert_redirected_to :controller => 'management/creatures', :action => 'index'
		assert flash[:notice] =~ /Added to preference/
		assert flash[:notice] =~ /sucessfully armed/
		
		get 'arm_creature', {:id => @c.id}, session
		assert_redirected_to :controller => 'management/creatures', :action => 'index'
		assert flash[:notice] =~ /Could not be/
	end
	
	test "mgmt creature controller pref list redirector" do
		get 'pref_lists', {}, session
		assert_redirected_to :controller => 'management/pref_list'
		assert session[:pref_list_type] == PrefListCreature
	end
end