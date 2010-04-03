class Image < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :player

	has_many :npcs
	has_many :creatures
	has_many :features
	has_many :player_characters
	
	validates_presence_of :image_type
	
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
	
	def update_image(new_image_text, rowcap=0, colcap=0)
		self.image_text = new_image_text
		self.resize_image(rowcap,colcap)
	end
	
	def resize_image(rowcap,colcap)
		return self.image_text if rowcap < 1 || colcap < 1
		it = self.image_text
		it.gsub!(/\r/,"") #ie adds this character, it must go
		it = it.split("\n")
		(rowcap < it.size ? rowcap : it.size).times{|r|
			it[r] = ( it[r].length <= colcap ? it[r] + " "*(colcap-it[r].length) : it[r][0..colcap-1] ) }
		it = ( it.size <= rowcap ? it + Array.new(rowcap-it.size, (" "*colcap)) : it[0..rowcap-1] )
		self.image_text = it.join "\n"
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
