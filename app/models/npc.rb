class Npc < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :kingdom
	belongs_to :image

	#has_one :event_npc
	has_one :nonplayer_character_killer
	has_one :npc_merchant_detail
	has_one :health,		:foreign_key => 'owner_id', :class_name => 'HealthNpc'
	has_one :stat,			:foreign_key => 'owner_id', :class_name => 'StatNpc'

	has_many :event_npcs
	has_many :items
	has_many :illnesses,  :foreign_key => 'owner_id', :class_name => 'NpcDisease'

	def self.set_npc_stats(npc,iHP,istr,idex,icon,iint,idam,idfn,imag,idelta)
		basehp = rand(idelta*4) + iHP
		HealthNpc.create( :owner_id => npc.id,
											:wellness => SpecialCode.get_code('wellness','alive'),
											:HP => basehp,
											:base_HP => basehp)
		StatNpc.create( :owner_id => npc.id,
										:str => rand(idelta) + istr,
										:dex => rand(idelta) + idex,
										:con => rand(idelta) + icon,
										:int => rand(idelta) + iint,
										:dam => rand(idelta) + idam,
										:dfn => rand(idelta) + idfn,
										:mag => rand(idelta) + imag )
	end
	
	def award_exp(exp)
		#do nothing
	end
	
	def drop_nth_of_gold(n)
		PlayerCharacter.transaction do
			self.lock!
			@amount = self.gold / n
			self.gold -= @amount
			self.save!
		end
		@amount || 0
	end

	#Pagination related stuff
	def self.per_page
		10
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'name' )
	end
end
