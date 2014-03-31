require 'test_helper'

class ImageTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@kingdom = Kingdom.first
		@image = Image.find_by_name("Test pc image")
		@feature_text =	"123456789012345\n" +
										"AAAaaaBBBbbbCCCccc\n" +
										"3\r\n" +
										"4\r\n" +
										"5\r\n" +
										"6\r\n" +
										"7\n" +
										"8\n" +
										"9             xoff\n" +
										"bottom line 10\n" +
										"should be cut off"
		@creature_text =	"I am longer than the fifteen column limit\n" +
											"which means for the creature, it should not be cropped at all\n" +
											"\n" +
											"\n" +
											"blah blah blah"
	end
	
	test "image deep_copy" do
		@copied = Image.deep_copy(@image)
		assert @copied.id.nil?
		assert @copied.image_text == @image.image_text
		assert @copied.player_id == @image.player_id
		assert @copied.public == @image.public
		assert @copied.kingdom_id == @image.kingdom_id
		assert @copied.image_type == @image.image_type
		assert @copied.picture == @image.picture
		assert @copied.name == @image.name
		assert @copied.save!
		assert @copied.id
	end
	
	test "image self.new_castle(k)" do
		@new_castle = Image.new_castle(@kingdom)
		assert @new_castle.id
		assert @new_castle.kingdom_id == @kingdom.id
		assert @new_castle.player_id == -1
	end
	
	test "image resize_image" do
		@new_f_image = Image.new(:image_text => @feature_text)
		
		@new_f_image.resize_image(10,15)
		assert @new_f_image.image_text !~ /off/
		assert @new_f_image.image_text != @feature_text
		assert @new_f_image.image_text.split("\n").size == 10
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
		
		@new_f_image.image_text[0] = "&"
		
		@new_f_image.resize_image(10,15)
		assert @new_f_image.image_text !~ /off/
		assert @new_f_image.image_text =~ /&/
		assert @new_f_image.image_text != @feature_text
		assert @new_f_image.image_text.split("\n").size == 10
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
		
		@new_f_image.image_text = "m"
		@new_f_image.resize_image(10,15)
		assert @new_f_image.image_text != @feature_text
		assert @new_f_image.image_text.split("\n").size == 10, @new_f_image.image_text.split("\n").size
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
	end
	
	test "image update_image" do
		@new_f_image = Image.new(:image_text => "bob")
		@new_c_image = Image.new(:image_text => "bob")
		
		@new_f_image.update_image(@feature_text)
		assert @new_f_image.image_text == @feature_text
		@new_f_image.update_image(@feature_text, 10, 15)
		assert @new_f_image.image_text != @feature_text
		assert @new_f_image.image_text.split("\n").size == 10, @new_f_image.image_text.split("\n").size
		@new_f_image.image_text.split("\n").each{|r|
			assert r.length == 15 }
		
		@new_c_image.update_image(@creature_text)
		assert @new_c_image.image_text == @creature_text
		@new_c_image.update_image(@creature_text,-1, -1)
		assert @new_c_image.image_text == @creature_text
	end
end
