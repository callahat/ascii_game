class Image < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :player

	has_many :npcs
	has_many :creatures
	has_many :features
	has_many :player_characters
	
	def self.deep_copy(image)
		@copy_image = Image.new
		@copy_image.image_text = image.image_text
		@copy_image.player_id = image.player_id
		@copy_image.public = image.public
		@copy_image.kingdom_id = image.kingdom_id
		@copy_image.image_type = image.image_type
		@copy_image.name = image.name

		return @copy_image
	end
	
	def self.new_castle(k)
		@image = Image.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', 'DEFAULT CASTLE', -1, -1])
		@new_image = Image.deep_copy(@image)
		@new_image.kingdom_id = k.id
		@new_image.name = k.name + " Castle Image"
		@new_image.save!
		@new_image
	end
	
	#Pagination related stuff
	def self.per_page
		10
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => 'image_type,name' )
	else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => 'image_type,name' )
	end
	end
end
