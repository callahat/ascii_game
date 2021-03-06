class Creature < ActiveRecord::Base
  belongs_to :image
  belongs_to :disease
  belongs_to :player
  belongs_to :kingdom

  has_one :genocide
  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatCreature', dependent: :destroy

  has_many :creature_kills
  has_many :event_creatures, :foreign_key => 'thing_id'
  has_many :quest_creature_kills

  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :stat

  validates_uniqueness_of :name
  validates_presence_of :name,:experience,:HP,:gold,:image,:stat,:player_id,:kingdom_id,:number_alive,:fecundity

  before_validation :update_exp_value

  def self.exp_worth(dam,dfn,hp,fec)
    if dam.nil? || dfn.nil? || hp.nil? || fec.nil?
      0
    else
      @damhp = dam.to_i - hp.to_i
      if 1 > @damhp
        @damhp = 1
      end
      @dfnhp = dfn.to_i - hp.to_i
      if 1 > @dfnhp
        @dfnhp = 1
      end
      
      return((exp_worth_helper(dam / @damhp) + exp_worth_helper(dfn / @dfnhp) + hp.to_i / (fec.abs + 1)).ceil() *5)
    end
  end

  def self.exp_worth_helper(mod)
    if mod.nil? || mod <= 0
      0
    elsif mod <= 10
      mod * 2
    elsif mod <= 100
      (mod-10) * 4 + 20
    else
      (mod-100) * (mod-100) + 380
    end
  end

  def self.update_all_exps
    @creatures = Creature.all.order(:name)
    @creatures.each{|c|
      print "Updating " + c.name + " from " + c.experience.to_s + " to "
      c.experience = Creature.exp_worth(c.stat.dam, c.stat.dfn, c.HP, c.fecundity)
      print c.experience.to_s
      if c.save
        print " sucessfully\n"
      else
        print " failed\n"
      end
    }
    nil
  end

  #returns the number reserved
  def reserve_creatures(number)
    return number if self.number_alive == -1
    @number = ( self.number_alive > number ? number : self.number_alive )
    Creature.transaction do
      self.lock!
      self.number_alive -= @number
      self.being_fought += @number
      self.save!
    end
    @number
  end

  def award_exp(exp)
    #do nothing
  end

  def update_exp_value
    self.experience = self.class.exp_worth(stat.try(:dam),stat.try(:dfn),self.HP,self.fecundity)
  end

  def attributes_with_nesteds
    attributes.merge(
      stat_attributes: stat.attributes.slice(*Stat.symbols.map(&:to_s)),
      image_attributes: image.attributes.slice('image_text','image_type','picture','name')
    )
  end

  #Pagination related stuff
  def self.get_page(page, pid = nil, kid = nil)
    where((pid || kid)? ['player_id = ? or kingdom_id = ?', pid, kid] : [] ) \
      .order('armed,name') \
      .paginate(:per_page => 20, :page => page)
  end
end
