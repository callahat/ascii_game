require 'test_helper'

class Management::ImagesControllerTest < ActionController::TestCase
	def setup
		sign_in Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:kingdom] = Kingdom.find_by_name("HealthyTestKingdom")
		
		@f_image = images(:feature_image)
		@c_image = images(:creature_image2)
		@pc_image = images(:pc_image)
		@ci_hash = {:image_text => "###\n###\n#H#", :image_type => SpecialCode.get_code('image_type','creature'),
							  :name => 'NewCreatureImg'}
		@fi_hash = {:image_text => "###\n###\n#H#", :image_type => SpecialCode.get_code('image_type','kingdom'),
							  :name => 'NewFeatureImg'}
	end

		
	test "mgmt image controller index" do
		get 'index', {}
		assert_response :success
		assert_not_nil assigns(:images)
	end
	
	test "mgmt image controller show" do
		get 'show', {:id => @c_image.id}
		assert_response :success
		assert_not_nil assigns(:image)
	end
	
	test "mgmt creature controller new and create" do
		get 'new', {}
		assert_response :success
		
		post 'create', {:image => {:image_text => ""}}
		assert_response :success
		assert_template 'new'
		
		assert_difference 'Image.count', +1 do
			post 'create', { :image => @ci_hash }
			assert_response :redirect
			assert_redirected_to :controller => 'management/images', :action => 'index'
		end
		@new_c_image = Image.find_by_name("NewCreatureImg")
		assert @new_c_image.image_text == @ci_hash[:image_text]
		
		assert_difference 'Image.count', +1 do
			post 'create', { :image => @fi_hash }
			assert_response :redirect
			assert_redirected_to :controller => 'management/images', :action => 'index'
		end
		@new_f_image = Image.find_by_name("NewFeatureImg")
		assert @new_f_image.image_text.split("\n").size == 10
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
	end
	
	test "mgmt image controller edit and update" do
		get 'edit', {:id => @c_image.id}
		assert_response :success
		
		orig_c_image = @c_image.image_text
		
		post 'update', {:id => @c_image.id, :image => {:image_type => ""} }
		assert_response :success
		assert_template 'edit'
		
		post 'update', {:id => @c_image.id, :image => @c_image.attributes }
		assert_response :redirect
		assert_redirected_to :controller => 'management/images', :action => 'show', :id => @c_image.id
		assert flash[:notice] =~ /updated/
		@new_c_image = Image.find(@c_image.id)
		assert @new_c_image.image_text == orig_c_image
		
		get 'edit', {:id => @f_image.id}
		assert_response :success
		
		orig_f_image = @f_image.image_text
		
		post 'update', {:id => @f_image.id, :image => {:image_type => ""} }
		assert_response :success
		assert_template 'edit'
		
		post 'update', {:id => @f_image.id, :image => @f_image.attributes }
		assert_response :redirect
		assert_redirected_to :controller => 'management/images', :action => 'show', :id => @f_image.id
		assert flash[:notice] =~ /updated/
		@new_f_image = Image.find(@f_image.id)
		assert_equal 10, @new_f_image.image_text.split("\n").size
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
	end
	
	test "mgmt image controller destroy" do
		assert_no_difference 'Image.count' do
			post 'destroy', {:id => @f_image.id}

			assert_redirected_to :controller => 'management/images', :action => 'index'
			assert_match /in use/, flash[:notice]
		end
		
		assert_difference 'Image.count', -1 do
			post 'destroy', {:id => @c_image.id}
			assert_redirected_to :controller => 'management/images', :action => 'index'
			assert flash[:notice] =~ /Image was destroyed/
		end
	end
end
