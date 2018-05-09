class StatCClass < Stat
  belongs_to :c_class, :foreign_key => 'owner_id'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'CClass'

  validate :valid_for_level_zero

  #How many experience points it would require for level
  def total_exp_for_level(l)
    attr = self.dup
    cost = attr.exp_for_level(l)
    cost += attr.c_class.spell_xp(l)
    cost
  end
end
