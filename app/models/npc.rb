class Npc < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :image

	#has_one :event_npc
	has_one :nonplayer_character_killer
	has_one :npc_merchant_detail
	has_one :health,		:foreign_key => 'owner_id', :class_name => 'HealthNpc'
	has_one :stat,			:foreign_key => 'owner_id', :class_name => 'StatNpc'

  has_many :event_npcs
  has_many :items
  has_many :npc_blacksmith_items
  has_many :npc_blacksmith_items_by_min_sales, :foreign_key => 'npc_id', :class_name => 'NpcBlacksmithItem', :order => 'min_sales'
  has_many :npc_stocks, :foreign_key => 'owner_id', :class_name => 'NpcStock'
  has_many :illnesses,  :foreign_key => 'owner_id', :class_name => 'NpcDisease'
  
  def self.gen_stock_guard(kingdom_id)
    @kingdom_name = Kingdom.find(kingdom_id).name
    @image = Image.find(:first, :conditions => ['name = ? and kingdom_id = ?', @kingdom_name + " Guard Image", kingdom_id])
    
    if @image.nil?
      @base_image = Image.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', "GUARD IMAGE", -1, -1])
      @image = Image.deep_copy(@base_image)
      @image.kingdom_id = kingdom_id
      @image.name = @kingdom_name + " Guard Image"
      @image.save
    end
    
    @name = "Guard " + Name.gen_name
    
    @new_stock_guard = Npc.new
    @new_stock_guard.name = @name
    @new_stock_guard.kingdom_id = kingdom_id
    @new_stock_guard.npc_division = SpecialCode.get_code('npc_division','guard')
    
    @new_stock_guard.gold = rand(50)
    @new_stock_guard.experience = 100
    @new_stock_guard.is_hired = true
    @new_stock_guard.image_id = @image.id
    
    if !@new_stock_guard.save
      print "\nFailed to save the new stock guard"
    end
		Npc.set_npc_stats(@new_stock_guard,60,10,10,10,10,10,10,10,30)

    
    return @new_stock_guard
  end
  
  def self.gen_stock_merchant(kingdom_id)
    @new_image = Image.deep_copy(Image.find(:first, :conditions => ['name = ?', 'DEFAULT NPC']))
    @new_image.kingdom_id = kingdom_id
    @new_image.save
  
    @new_merch = Npc.new
    @new_merch.kingdom_id = kingdom_id
    @new_merch.npc_division = SpecialCode.get_code('npc_division','merchant')
    
    @new_merch.gold = rand(50)
    @new_merch.experience = 100
    @new_merch.is_hired = false
    @new_merch.image_id = @new_image.id
    
    @new_merch.name = Name.gen_name
     
    
    if !@new_merch.save
      print @new_merch.errors.full_messages + "\n"
    end
    Npc.set_npc_stats(@new_merch,60,10,10,10,10,10,10,10,30)

    if rand > 0.65   #NPC gets a title
      @new_merch.name += " the " + NameTitle.get_title(@new_merch.stat.con, @new_merch.stat.dam, @new_merch.stat.dex,                                                       @new_merch.stat.dfn, @new_merch.stat.int, @new_merch.stat.mag,                                                       @new_merch.stat.str).capitalize
    end

    @new_image.name = @new_merch.name + " image"
    @new_image.save
    
    #what kinda merchant is it?
    @merch_attribs = Npc.gen_merch_attribs(@new_merch)
    @merch_attribs.save
    
    #extra setup if its a blacksmith
    if @merch_attribs.blacksmith_sales
      #make up a new item for the blacksmith!
      NpcBlacksmithItem.gen_blacksmith_items(@new_merch, @merch_attribs.blacksmith_sales, false)
    end
    
    return @new_merch
  end
  
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
	
	def self.gen_merch_attribs(npc)
		@npc_merch = NpcMerchant.new
		@npc_merch.npc_id = npc.id
		@npc_merch.consignor = rand(2)
		if npc.kingdom && npc.kingdom.player_character_id
			@npc_merch.race_body_type = npc.kingdom.player_character.race.race_body_type
		end
		
		@types = rand
		
		if @types < 0.7	 #one merchant type
			@sub = rand(3)
			if @sub == 0
				@npc_merch.healing_sales = 10
			elsif @sub == 1
				@npc_merch.blacksmith_sales = 10
			else	#@sub == 3
				@npc_merch.trainer_sales = 10
			end
		elsif @types < 0.9	#two merchant types
			@sub = rand(3)
			if @sub == 0
				@npc_merch.healing_sales = 10
				@npc_merch.blacksmith_sales = 10
			elsif @sub == 1
				@npc_merch.blacksmith_sales = 10
				@npc_merch.trainer_sales = 10
			else	#@sub == 3
				@npc_merch.healing_sales = 10
				@npc_merch.trainer_sales = 10
			end
		else	 #all three merchant types
			@npc_merch.healing_sales = 10
			@npc_merch.blacksmith_sales = 10
			@npc_merch.trainer_sales = 10
		end
		
		return @npc_merch
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
