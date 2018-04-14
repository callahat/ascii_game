require 'test_helper'

class Management::LevelsControllerTest < ActionController::TestCase
	def setup
		# sign_in Player.find_by_handle("Test Player One")
		# session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		# session[:kingdom] = Kingdom.find_by_name("HealthyTestKingdom")
		
		# @f_armed = Feature.find_by_name("Creature Feature One")
		# @level1 = session[:kingdom].levels.first
	end
	
	test "mgmt level controller index" do
		# get 'index', {}
		# assert_response :success
		# assert_not_nil assigns(:features)
	end
	
	test "mgmt level controller show" do
		# get 'show', {:id => @f.id}
		# assert_response :success
		# assert_not_nil assigns(:feature)
	end
	
	test "mgmt level controller new and create" do
		# get 'new', {}
		# assert_response :success
		
		# post 'create', {:feature => {}, :image => {:image_text => ""}}
		# assert_response :success
		# assert_template 'new'
		
		# assert_difference 'Feature.count', +1 do
			# post 'create', { :feature => @f_hash, :image => @i_hash }
			# assert_response :redirect
			# assert_redirected_to :controller => 'management/features', :action => 'index'
		# end
		# @new_f_image = Feature.find_by_name("New Feature Name").image
		# assert @new_f_image.image_text.split("\n").size == 10
		# @new_f_image.image_text.split("\n").each{|r|
			# assert r.length == 15 }
	end
	
	test "mgmt level controller edit and update" do
		# Add later
	end
end
