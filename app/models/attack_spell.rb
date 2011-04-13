class AttackSpell < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name,:min_level,:min_dam,:max_dam,:dam_from_mag,:dam_from_int,:mp_cost,:hp_cost
  
  def self.find_spells(level)
    find_by_sql("select * from attack_spells where min_level <= #{level} order by min_level")
  end

  #battle related
  #nil if cannot pay
  def pay_casting_cost(pc)
    Health.transaction do
      pc.health.lock!
      if pc.health.MP >= self.mp_cost && pc.health.HP >= self.hp_cost
        pc.health.MP -= self.mp_cost
        pc.health.HP -= self.hp_cost
        @paid = true
      else
        @paid = false
      end
      pc.health.save!
    end
    @paid
  end
  
  def magic_dam(int,mag)
    dfm = rand( self.dam_from_mag * (mag > 0 ? mag : 0) )
    dfi = self.dam_from_int * (int > 0 ? int : 0)
    return (rand(self.max_dam - self.min_dam) + self.min_dam + dfm + dfi).to_i
  end
  
  #Pagination related stuff
  def self.get_page(page, l = nil)
    order('min_level,name') \
      .where( l ? ['min_level <= ?', l] : [] ) \
      .paginate(:per_page => 20, :page => page)
  end
end
