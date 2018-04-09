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
		@i_hash = {:image_text => "                -_o                ", :image_type => SpecialCode.get_code('image_type','creature'),
							:player_id => session[:player][:id], :kingdom_id => session[:kingdom][:id]}
	end
	
	test "mgmt creature controller index" do
		get 'index', {}
		assert_response :success
		assert_not_nil assigns(:creatures)
	end
	
	test "mgmt creature controller show" do
		get 'show', {:id => @c.id}
		assert_response :success
		assert_not_nil assigns(:creature)
	end
	
	test "mgmt creature controller new and create" do
		get 'new', {}
		assert_response :success

		post 'create', {creature: {name: ''}, image: {}, stat: {}}
		assert_response :success
		assert_template 'new'
		
		assert_difference 'Creature.count', +1 do
			post 'create', { :creature => @c_hash.merge(image_attributes: @i_hash, stat_attributes: @s_hash)}
			assert_response :redirect
			assert_redirected_to management_creature_path(assigns(:creature))
		end
		@new_c_image = Creature.find_by_name("New creature Name").image
		assert @new_c_image.image_text == @i_hash[:image_text]
	end

  test "mgmt creature controller new and create using a prebaked image" do
    assert_difference 'Creature.count', +1 do
      post 'create', { :creature => @c_hash.merge(image_id: Image.first.id, image_attributes: @i_hash, stat_attributes: @s_hash)}
      assert_response :redirect
      assert_response :redirect
      assert_redirected_to management_creature_path(assigns(:creature))
    end
    @new_c_image = Creature.find_by_name("New creature Name").image
    assert_equal Image.first.image_text, @new_c_image.image_text
    assert_not_equal @i_hash[:image_text], @new_c_image.image_text
  end
	
	test "mgmt creature controller edit" do
		get 'edit', {:id => @c.id}
		assert_response :success
  end

  test "mgmt creature controller update" do
		orig_c_image = @c.image.image_text

		patch 'update', {:id => @c.id, creature: {:gold => nil, image_attributes: @c.image.attributes, stat_attributes: {}} }
		assert_response :success
		assert_template 'edit'
		
		patch 'update', {:id => @c.id, :creature => @c.attributes.merge(image_attributes: @c.image.attributes, stat_attributes: {})}
		assert_response :redirect
		assert_redirected_to management_creatures_path
		assert flash[:notice] =~ /updated/
		@new_c_image = Creature.find(@c.id).image
		assert @new_c_image.image_text == orig_c_image
	end
	
	test "mgmt creature controller destroy" do
		assert_no_difference 'Creature.count' do
			delete 'destroy', {:id => @c_armed.id}
			assert_redirected_to management_creatures_path
			assert flash[:notice] =~ /being used/
		end
		
		assert_difference 'Creature.count', -1 do
			post 'destroy', {:id => @c.id}
			assert_redirected_to management_creatures_path
			assert flash[:notice] =~ /Creature destroyed/
		end
	end
	
	test "mgmt creature controller arm" do
		get 'arm', {:id => @c_armed.id}
		assert_redirected_to management_creatures_path
		assert flash[:notice] =~ /Could not be/

		get 'arm', {:id => @c.id}
		assert_redirected_to management_creatures_path
		assert flash[:notice] =~ /Added to preference/
		assert flash[:notice] =~ /sucessfully armed/
		
		get 'arm', {:id => @c.id}
		assert_redirected_to management_creatures_path
		assert flash[:notice] =~ /Could not be/
	end
	
	test "mgmt creature controller pref list redirector" do
		get 'pref_lists', {}
		assert_redirected_to :controller => 'management/pref_list'
		assert session[:pref_list_type] == PrefListCreature
	end
end
