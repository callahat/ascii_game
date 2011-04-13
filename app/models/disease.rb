class Disease < ActiveRecord::Base
  has_one :creature

  has_many :event_diseases
  has_many :healer_skills
  has_many :healing_spells
  has_many :infections
  has_many :pandemics
  has_many :npc_diseases
  has_many :illnesses

  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatDisease'

  validates_uniqueness_of :name
  validates_presence_of :name,:virility,:trans_method,:HP_per_turn,:MP_per_turn, :peasant_fatality,:min_peasants


  def self.abs_cost(d)
    return ((d.stat.abs_sum_points + d.HP_per_turn.to_i.abs + d.MP_per_turn.to_i.abs) * (d.virility.to_i.abs + 1)).to_i
  end

  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 20, :page => page)
  end
end
