class Genocide < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :creature
	
	def self.create_genocide_row(player_character_id, pc_level, creature_id, how)
		@genocide = Genocide.new
		@genocide.player_character_id = player_character_id
		@genocide.level = pc_level
		@genocide.when = Time.now
		@genocide.creature_id = creature_id
		@genocide.how_eliminated = SpecialCode.get_text('how_eliminated',how)
		if !@genocide.save
			print "\nGenocide failed to save!" + @genocide.display
		end
	end
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page, pcid = nil)
		if pcid.nil?
		paginate(:page => page, 
				 :joins => "INNER JOIN creatures on genocides.creature_id = creatures.id",
				 :order => 'creatures.name' )
	else
			paginate(:page => page,
						 :conditions => ['player_character_id = ?', pcid],
						 :joins => "INNER JOIN creatures on genocides.creature_id = creatures.id",
						 :order => 'creatures.name' )
	end
	end
end
