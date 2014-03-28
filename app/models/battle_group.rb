class BattleGroup < ActiveRecord::Base
  belongs_to :battle
  has_many :enemies, :through => :battle
  has_many :creatures, :through => :battle
  has_many :npcs, :through => :battle
  has_many :merchants, :through => :battle
  has_many :guards, :through => :battle
  has_many :pcs, :through => :battle
  
  def rename
    dudes = []
    dudes << self.pcs.collect{|which| which.pc.name}
    dudes << self.merchants.collect{|which| which.npc.name}
    dudes << [self.guards.size.to_s + ( self.guards.size > 1 ? " guards" : " guard")] if self.guards.size > 0
    if self.creatures.size > 0
      cname = self.creatures[0].enemy.name
      dudes << [(self.creatures.size.to_s + " " + ( self.creatures.size > 1 ? cname.pluralize : cname))]
    end
    foo = dudes.flatten!.pop
    self.name = dudes.join(", ").to_s
    self.name += " and " if dudes.size > 0
    self.name += foo.to_s
    self.save!
  end
end
