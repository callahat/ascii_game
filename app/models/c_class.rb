class CClass < ActiveRecord::Base
  has_many :player_characters

  has_one :level_zero, :foreign_key => 'owner_id', :class_name => 'StatCClass', dependent: :destroy
  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatCClass'

  accepts_nested_attributes_for :level_zero

  attr_accessible :name, :description, :attack_spells, :healing_spells, :freepts, :level_zero_attributes

  validates_uniqueness_of :name
  validates_presence_of :name, :freepts, :level_zero
  
  def spell_xp(l)
    xp = 0
    if attack_spells
      xp += 15 * (l ** 1.5).to_i
    end
    if healing_spells
      xp += 15 * (l ** 1.2).to_i
    end
    xp
  end

  def attributes_with_nesteds
    attributes.merge level_zero_attributes: level_zero.attributes.slice(*Stat.symbols.map(&:to_s))
  end
  
  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 10, :page => page)
  end
end
