class Health < ActiveRecord::Base
  self.inheritance_column = 'kind'

  #attr_accessible :owner_id, :HP,:MP,:base_HP,:base_MP,:wellness
  
  def self.symbols
    [:wellness, :HP, :MP, :base_HP, :base_MP]
  end
  
  def adjust_for_stats(st, lvl)
    self.HP -= self.base_HP
    self.MP -= self.base_MP
    
    self.base_HP =  st[:con] * 3 + 
                   (st[:str] / lvl ) / 2 +
                   (st[:dfn] / 10 ).floor + lvl / 2
           
    self.base_MP = ((st[:mag] / 2) * 
                    (st[:int] / 2) * lvl.**(0.25) ) / 10
    
    self.HP += self.base_HP
    self.MP += self.base_MP
  end
  
  #goes through the stat symbols and looks for them in the given object
  #returns the hash. Stat symbol is zero if no attribute in object
  def self.to_symbols_hash(b)
    Health.symbols.inject({}) {|h,sym| h.merge( {sym => (b[sym].nil? ? 0 : b[sym])} ) }
  end
  
  #battle
  def inflict_damage(amount)
    damaged = (self.HP > amount ? amount : self.HP)
    Health.transaction do
      self.lock!
      self.HP -= damaged
      if self.HP <= 0
        self.wellness = SpecialCode.get_code('wellness', 'dead')
      end
      self.save!
    end
    ( (amount - damaged) > 0 ? amount - damaged : 0 )   #return the overflow
  end
end
