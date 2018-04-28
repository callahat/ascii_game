class NpcBlacksmithItem < ActiveRecord::Base
  belongs_to :npc_merchant, foreign_key: 'npc_id'
  belongs_to :item

  scope :by_min_sales, -> { order('min_sales') }
  
  def self.gen_blacksmith_items(npc, sales, new)
    @last_min_sales = npc.npc_blacksmith_items.by_min_sales.last
    @last_min_sales = ( @last_min_sales ? @last_min_sales.min_sales : -1 )
    
    @skill_base_items = BlacksmithSkill.find_base_items(sales, @last_min_sales, npc.npc_merchant_detail.race_body_type).includes(base_item: :stat)
    
    @new_items = []
    
    #base items
    for item in @skill_base_items #create new rows for each
      if item.min_sales > @last_min_sales || rand > 0.7
        @new_items << self.gen_blacksmith_item(npc, item.min_sales, item.base_item, item.min_mod, item.max_mod, new)
        @last_min_sales = item.min_sales
      end
    end
    
    #remove warning messages later.
    @new_items.collect{|new_item|
      (new_item.save ? "NPC " + npc.name + " can now make blacksmith item " + new_item.item.name :
                      "Failed to save new balcksmith item: " + new_item.item.name + " for NPC: " + npc.name )
    }
  end
  
  #generate one blacksmith item row. Probably should be protected method, but we'll see,
  #there may be some use to use this outside of NPC creation and NPC experience gains.
  def self.gen_blacksmith_item(npc, sales, base_item, min_mod, max_mod, new)
    if new #just make a new item
      @new_item = Item.create(:name => "Temp Name",
                              :min_level => 0,
                              :equip_loc => base_item.equip_loc, 
                              :base_item_id => base_item.id,
                              :npc_id => npc.id,
                              :race_body_type => base_item.race_body_type,
                              :price => base_item.price * 10 )

      @new_item_stat = StatItem.new(:owner_id => @new_item.id)
      Stat.symbols.each{|sym|
        @new_item_stat[sym] = rand(max_mod) + min_mod + base_item.stat[sym]
        @new_item.price += @new_item_stat[sym] ** 1.5 }
      @new_item_stat.save!
      
      @new_item.price /= 10
      
      #new items will be preferred by the class and race of the current king, if one exists
      if npc.kingdom && npc.kingdom.player_character
        @new_item.c_class_id = npc.kingdom.player_character.c_class_id
        @new_item.race_id = npc.kingdom.player_character.race_id
      end
      
      @new_item_title = NameTitle.get_title(@new_item_stat.con, @new_item_stat.dam, @new_item_stat.dex,
                                            @new_item_stat.dfn, @new_item_stat.int, @new_item_stat.mag,
                                            @new_item_stat.str)
      @new_item.name = npc.name + "'s " + @new_item_title + " " + base_item.name
      @new_item.min_level = @new_item_stat.sum_points**1.1983 / 7
      
      return(nil) && Rails.logger.warn("Failed to save new blacksmith item") unless @new_item.save!
      return self.new(:npc_id => npc.id, 
                      :item_id => @new_item.id,
                      :min_sales => sales)
    else #check that a comprable item exists and can be made, otherwise fallback on generateing new item
      if ( @next_item_level_rough_price = BlacksmithSkill.find_by(['min_sales > ?',sales]) )
        @next_item_level_rough_price = @next_item_level_rough_price.min_sales
      else
        @next_item_level_rough_price = sales ** 1.234
      end
      
      if @prefab_item = Item.where(npc_id: nil, base_item_id: base_item.id) \
                            .order('rand()') \
                            .find_by( ['price < ? and price > ?',
                                       @next_item_level_rough_price / 40,
                                       @next_item_level_rough_price / 60])
        return self.new(:npc_id => npc.id,
                        :item_id => @prefab_item.id,
                        :min_sales => sales)
      else
        return self.gen_blacksmith_item(npc, sales, base_item, min_mod, max_mod, true)
      end
    end
  end
end
