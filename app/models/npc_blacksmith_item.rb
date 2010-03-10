class NpcBlacksmithItem < ActiveRecord::Base
	belongs_to :npc
	belongs_to :item
	
	#generate many skills. Use on the higher level skills, as all generated skill rows will have the same min_sales
	#comment this out when not actually using it.
	#def self.gen_skills(min_mod, max_mod, sales)
	#	@base_items = BaseItem.find_all
	#	
	#	for base_item in @base_items
	#		@skill = BlacksmithSkill.new
	#		@skill.min_mod = min_mod
	#		@skill.max_mod = max_mod
	#		@skill.min_sales = sales
	#		@skill.base_item_id = base_item.id
	#		if !@skill.save
	#			print "\nFailed to save the new blacksmith skill"
	#		else
	#			print "\n" + @skill.base_item.name
	#		end
	#	end
	#	return nil
	#end
	
	
	def self.gen_blacksmith_items(npc, sales, new)
		@last_min_sales = npc.npc_blacksmith_items_by_min_sales.last
		if @last_min_sales
			@last_min_sales = @last_min_sales.min_sales
		else
			@last_min_sales = 0
		end
		
		if npc.npc_merchant.race_body_type.nil? #if merchant has no restrictions, can make anything
			@skill_base_items = BlacksmithSkill.find(:all, :conditions => ['min_sales <= ? and min_sales > ?', sales, @last_min_sales], :order => 'min_sales')
		else
			@skill_base_items = BlacksmithSkill.find(:all, :include => 'base_item', :conditions => ['min_sales <= ? and min_sales > ? and (base_items.race_body_type is null or base_items.race_body_type = ?)', sales, @last_min_sales, npc.npc_merchant.race_body_type], :order => 'min_sales')
		end
		@new_items = []
		
		#base items
		for item in @skill_base_items	 #create new rows for each
			if item.min_sales > @last_min_sales || rand > 0.7
				@new_items << self.gen_blacksmith_item(npc, item.min_sales, item.base_item, item.min_mod, item.max_mod, new)
				@last_min_sales = item.min_sales
			end
		end
		
		#remove warning messages later.
		for new_item in @new_items
			if !new_item.save
				print "\nFailed to save new balcksmith item: " + new_item.item.name + " for NPC: " + npc.name
			else
				print "\nNPC " + npc.name + " can now make blacksmith item " + new_item.item.name
			end
		end
	end
	
	#generate one blacksmith item row. Probably should be protected method, but we'll see,
	#there may be some use to use this outside of NPC creation and NPC experience gains.
	def self.gen_blacksmith_item(npc, sales, base_item, min_mod, max_mod, new)
		if new #just make a new item
			@new_item = Item.new
			@new_item.equip_loc = base_item.equip_loc
			@new_item.base_item_id = base_item.id
			@new_item.npc_id = npc.id

			@new_item.con = rand(max_mod) + min_mod
			@new_item.dam = rand(max_mod) + min_mod + base_item.dam_mod
			@new_item.dex = rand(max_mod) + min_mod
			@new_item.dfn = rand(max_mod) + min_mod + base_item.dfn_mod
			@new_item.int = rand(max_mod) + min_mod
			@new_item.mag = rand(max_mod) + min_mod
			@new_item.str = rand(max_mod) + min_mod
			
			@new_item.race_body_type = base_item.race_body_type
			
			@new_item.price = base_item.price + (@new_item.con**1.5 + @new_item.dex**1.5 + @new_item.dam**1.5 +
																					 @new_item.dfn**1.5 + @new_item.int**1.5 + @new_item.mag**1.5 +
																					 @new_item.str**1.5).to_i / 10
			
			#new items will be preferred by the class and race of the current king, if one exists
			if npc.kingdom && npc.kingdom.player_character
				@new_item.c_class_id = npc.kingdom.player_character.c_class_id
				@new_item.race_id = npc.kingdom.player_character.race_id
			end
			
			@new_item_title = NameTitle.get_title(@new_item.con, @new_item.dam, @new_item.dex,
																						@new_item.dfn, @new_item.int, @new_item.mag,
																						@new_item.str)
			@new_item.name = npc.name + "'s " + @new_item_title + " " + base_item.name
			
			@new_item.min_level = (@new_item.con + @new_item.dam + @new_item.dex +
														 @new_item.dfn + @new_item.int + @new_item.mag +
														 @new_item.str + 7)**1.1983 / 7
			
			if !@new_item.save
				print "\nFaield to save new blacksmith item"
			else
				print "\nCreated new item #" + @new_item.id.to_s + " " + @new_item.name
			end
			
			@npc_blacksmith_item = NpcBlacksmithItem.new
			@npc_blacksmith_item.npc_id = npc.id
			@npc_blacksmith_item.item_id = @new_item.id
			@npc_blacksmith_item.min_sales = sales
			return @npc_blacksmith_item
		else #check that a comprable item exists and can be made, otherwise fallback on generateing new item
			@next_item_level_rough_price = BlacksmithSkill.find(:first, :conditions => ['min_sales > ?',sales])
			if @next_item_level_rough_price
				@next_item_level_rough_price = @next_item_level_rough_price.min_sales
			else
				@next_item_level_rough_price = sales ** 1.234
			end
			
			@prefab_items = Item.find(:all, :limit => 7, :conditions => ['npc_id is null and base_item_id = ? and price < ? and price > ?', base_item.id, @next_item_level_rough_price / 40, @next_item_level_rough_price / 60])
			if @prefab_items.size == 0
				return self.gen_blacksmith_item(npc, sales, base_item, min_mod, max_mod, true)
			else
				@npc_blacksmith_item = NpcBlacksmithItem.new
				@npc_blacksmith_item.npc_id = npc.id
				@npc_blacksmith_item.item_id = @prefab_items[rand(@prefab_items.size)].id
				@npc_blacksmith_item.min_sales = sales
				return @npc_blacksmith_item
			end
		end
	end
end
