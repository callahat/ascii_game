class NpcMerchant < Npc
#  include TxWrapper
#  include MiscMath
  
  has_many :npc_blacksmith_items, :foreign_key => 'npc_id'
  has_many :npc_blacksmith_items_by_min_sales, ->{ order('min_sales') }, :foreign_key => 'npc_id', :class_name => 'NpcBlacksmithItem'
  has_many :npc_stocks, :foreign_key => 'owner_id', :class_name => 'NpcStock'
  
  has_one :npc_merchant_detail, :foreign_key => 'npc_id'

  def self.generate(kingdom_id)
    @new_image = Image.deep_copy(Image.find_by(name: 'DEFAULT NPC'))
    @new_image.kingdom_id = kingdom_id
    @new_image.save

    @new_merch = self.create(
        :kingdom_id => kingdom_id,
        :gold => rand(50),
        :experience => 100,
        :is_hired => false,
        :image_id => @new_image.id,
        :name => Name.gen_name
      )
    Npc.set_npc_stats(@new_merch,60,10,10,10,10,10,10,10,30)

    if rand > 0.65   #NPC gets a title
      @new_merch.name += " the " +
          NameTitle.get_title(@new_merch.stat.con, @new_merch.stat.dam, @new_merch.stat.dex,
            @new_merch.stat.dfn, @new_merch.stat.int, @new_merch.stat.mag,
            @new_merch.stat.str).capitalize
    end

    @new_image.name = @new_merch.name + " image"
    @new_image.save

    #what kinda merchant is it?
    @merch_attribs = self.gen_merch_attribs(@new_merch)
    @merch_attribs.save

    NpcBlacksmithItem.gen_blacksmith_items(@new_merch, @merch_attribs.blacksmith_sales, false) \
      if @merch_attribs.blacksmith_sales > 0

    return @new_merch
  end

  def self.gen_merch_attribs(npc)
    @rbt = npc.kingdom.player_character.race.race_body_type if npc.kingdom && npc.kingdom.player_character_id
    @kinds = 10
    @types = [0,0,0]
    
    if (@rtemp = rand) > 0.9
      @kinds = 30
    elsif @rtemp > 0.7
      @kinds = 20
    end
    
    while @types.sum < @kinds
      @types[rand(3)] = 10
    end
    
    NpcMerchantDetail.new(:npc_id => npc.id,
          :consignor => rand(2),
          :race_body_type => @rbt,
          :healing_sales => @types[0],
          :blacksmith_sales => @types[1],
          :trainer_sales => @types[2])
  end
  
  def pay(amount, sale_type)
    TxWrapper.give(self, :gold, amount)
    TxWrapper.give(self.npc_merchant_detail, sale_type, amount) if sale_type
  end
  
  def manufacture(pc, iid)
    if Item.exists?(:id => iid) && (@item = Item.find(iid)) && self.npc_blacksmith_items.exists?(:item_id => iid)
      @tax = (@item.price * (self.kingdom.tax_rate / 100.0)).to_i
      @cost = @item.price + @tax
    
      if TxWrapper.take(pc, :gold, @cost)
        PlayerCharacterItem.update_inventory(pc.id,@item.id,1)
        Kingdom.pay_tax(@tax, self.kingdom_id)
        self.pay(@item.price, :blacksmith_sales)
        [true, "Bought a " + @item.name + " for " + @cost.to_s + " gold."]
      else
        [false, "Insufficient gold"]
      end
    else
      [false, self.name + " cannot make " + (@item ? @item.name : "that" ) ]
    end
  end
  
  def cure_disease(pc, did)
    if (Disease.exists?(:id => did)) and (@disease = Disease.find(did)) and
        (self.npc_merchant_detail.healer_skills.collect{|cure| cure.disease_id }.compact.index(did))
      @pretax = Disease.abs_cost(@disease)
      @tax = (@pretax * (self.kingdom.tax_rate / 100.0)).to_i
    
      if TxWrapper.take(pc, :gold, @pretax + @tax)
        if Illness.cure(pc, @disease)
          self.pay(@pretax, :healing_sales) unless @pretax == 0
          Kingdom.pay_tax(@tax, self.kingdom_id) unless @tax == 0
          [true, 'Cured ' + @disease.name ]
        else
          TxWrapper.give(pc, :gold, @pretax + @tax)
          [false, 'Cannot cure what you do not have']
        end
      else
        [false, 'Not enough gold to cure ' + @disease.name ]
      end
    else
      [false, self.name + " cannot cure " + (@disease ? @disease.name : "that" ) ]
    end
  end
  
  def heal(pc, what)
    amount = self.max_heal(pc, what)
    @pretax = MiscMath.point_recovery_cost(amount)
    @tax = (@pretax * (self.kingdom.tax_rate / 100.0)).to_i
    
    if TxWrapper.take(pc, :gold, @pretax + @tax)
      TxWrapper.give(pc.health, what.to_sym, amount)
      self.pay(@pretax, :healing_sales) unless @pretax == 0
      Kingdom.pay_tax(@tax, self.kingdom_id) unless @tax == 0
      [true, 'Restored ' + what]
    else
      [false, 'Not enough gold to restore ' + what]
    end
  end
  
  def max_heal(pc, what)
    return 0 if pc.health["base_#{what}".to_sym] < pc.health[what.to_sym]
    MiscMath.min(
        self.npc_merchant_detail.healer_skills.first["max_#{what}_restore".to_sym],
        pc.health["base_#{what}".to_sym] - pc.health[what.to_sym]
      )
  end
  
  def train(pc, stats)
    #double check the max skill taught from what was entered
    Stat.symbols.each{|at|
      available_to_train = (pc.base_stat[at] * ( self.npc_merchant_detail.max_skill_taught / 100.0)).to_i
      training_points_spent  = (stats[at] + pc.trn_stat[at])

      if stats[at] < 0
        stats.errors.add(at, "cannot be negative")
      elsif training_points_spent > available_to_train
        stats.errors.add(at, "cannot gain " + stats[at].to_s + " points")
      end
    }

    return([false, '']) if stats.errors.size > 0
    
    @pretax = stats.sum_points * pc.level * 10
    @tax = (@pretax * self.kingdom.tax_rate / 100.0).to_i
    
    if TxWrapper.take(pc, :gold, @pretax + @tax)
      StatPcTrn.transaction do
        pc.trn_stat.lock!
        pc.stat.lock!
        pc.trn_stat.add_stats(stats)
        pc.stat.add_stats(stats)
        pc.trn_stat.save!
        pc.stat.save!
      end
    
      Kingdom.pay_tax(@tax, self.kingdom_id) unless @tax == 0
      self.pay(@pretax, :trainer_sales) unless @pretax == 0
      return true, "Training successful"
    else
      return false, "Not enough gold to train that much\n"
    end
  end
  
  def sell_used_to(pc, iid)
    if @stock = self.npc_stocks.find_by(item_id: iid) and
        NpcStock.update_inventory(self.id, @stock.item_id, -1)
      @pretax = @stock.item.used_price
      @tax = (@pretax * (self.kingdom.tax_rate / 100.0)).to_i
      
      if !TxWrapper.take(pc, :gold, @tax + @pretax)
        NpcStock.update_inventory(self.id, @stock.item_id, 1)
        [false, "Its out of your price range"]
      elsif PlayerCharacterItem.update_inventory(pc.id,@stock.item_id,1)
        Kingdom.pay_tax(@tax, self.kingdom_id)
        TxWrapper.give(self, :gold, @pretax)
        [true, "Bought a " + @stock.item.name + " for " + (@tax + @pretax).to_s + " gold." ]
      end
    else
      [false, self.name + " does not have " + (@stock ? "a " + @stock.item.name : "one of those" ) + " for sale."]
    end
  end
  
  def buy_from(pc, iid)
    if @pc_item = pc.items.find_by(item_id: iid) and
        PlayerCharacterItem.update_inventory(pc.id,@pc_item.item_id,-1)
      @cost = @pc_item.item.resell_value
      NpcStock.update_inventory(self.id,@pc_item.item_id,1)
      TxWrapper.give(pc, :gold, @cost)
      [true, "Sold a " + @pc_item.item.name + " for " + @cost.to_s + " gold."]
    else
      [false, "You do not have " + (@pc_item ? "a " + @pc_item.item.name : "one of those") + " to sell."]
    end
  end
end
