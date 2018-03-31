class Stat < ActiveRecord::Base
  self.inheritance_column = 'kind'

  validates_presence_of :str, :dex, :con, :int, :mag, :dfn, :dam
  attr_accessible :owner_id, :str, :dex, :con, :int, :mag, :dfn, :dam

  @@humanize = {
    :str => "strength",
    :dex => "dexterity",
    :con => "constitution",
    :int => "intelligence",
    :mag => "magic",
    :dfn => "defense",
    :dam => "damage"}

  def self.human_attr(attr)
    @@humanize[attr]
  end

  def save_level_zero
    ( valid_for_level_zero ? save : false )
  end

  def add_stats(s)
    Stat.symbols.each{|sym|
      self[sym] += s[sym] }
    self
  end

  #true if this object would be a validly distributed free points row
  def valid_distrib(free)
    Stat.symbols.each{|sym|
      if self[sym].to_i < 0
        errors.add(sym, " can't be negative.")
      end
    }
    points = self.sum_points
    errors.add(" ","distribued freepoints exceed the number available. (Current = " + points.to_s + ")") \
      if points > free
    errors.size == 0
  end

  def self.add_stats(s1, s2)
    ret = self.new
    Stat.symbols.each{|sym|
      ret[sym] = s1[sym] + s2[sym] }
    ret
  end

  def subtract_stats(s)
    Stat.symbols.each{|sym|
      self[sym] -= s[sym] }
    self
  end

  def valid_for_level_zero
    Stat.symbols.each{|sym|
      if self[sym].to_i < 0
        errors.add(sym, " can't be negative.")
      end
    }
    points = self.sum_points
    errors.add('',"attribute points must be between 30 and 80. (Current = " + points.to_s + ")") \
      if points < 30 || points > 80
    errors.size == 0
  end

  def est_level
    pts = self.sum_points
    if pts < 350
      pts / 6
    elsif pts < 1000
      pts / 7
    elsif pts < 2000
      pts / 8
    else
      pts / 10
    end
  end

  def sum_points
    sum = 0
    Stat.symbols.each{|a|
      sum += self[a].to_i }
    sum
  end

  def abs_sum_points
    sum = 0
    Stat.symbols.each{|a|
      sum += self[a].to_i.abs }
    sum
  end

  #This assumes the stat is a base at level 0
  def to_level(l)
    def self.get_next(m, l)
      if l < 20
        m + (m*l*0.1).round
      elsif l < 100
        m + 2*m + (m*(l-20)*0.05).round
      else
        m + 6*m + (m*(l-100)*0.15).round
      end
    end
    new_atr = self.class.new
    Stat.symbols.each{|a|
      tmp_next = get_next(self[a], l)
      new_atr[a] = ( tmp_next > self[a] ? tmp_next : self[a] )
    }
    new_atr
  end

  #How many experience points it would require for level
  def exp_for_level(l)
    def self.point_cost(pt, l)
      if l < 20
        pt*l*3
      elsif l < 100
        60*pt + ((pt*(l-20))*4.0**(1.0 + l/100.0)).round
      else
        1340*pt + (pt*(l-100)*5.0**(1.0 + l/100.0)).round
      end
    end
    cost = 0
    Stat.symbols.each{|a|
      cost += point_cost(Stat.mod_cost(self[a]), l)
    }
    cost += point_cost(Stat.mod_cost(self.owner[:freepts].to_i), l)
    cost
  end

  #The more points in something one has, the more expensive additional points become
  def self.mod_cost(m)
    if m < 40
      m
    elsif m < 100
      3*m - 80     #m + (m - 40)*2
    elsif m < 300
      6*m - 380    #3m - 80 + (m - 100)*3
    else
      10*m - 1580  #6m - 380 + (m-300)*4
    end
  end

  def self.symbols
    [:con,:dam,:dex,:dfn,:int,:mag,:str]
  end

  #goes through the stat symbols and looks for them in the given object
  #returns the hash. Stat symbol is zero if no attribute in object
  def self.to_symbols_hash(b)
    Stat.symbols.inject({}) {|h,sym| h.merge( {sym => (b[sym].nil? ? 0 : b[sym])} ) }
  end

  #battle related stuff
  def phys_dam
    return (self.str + self.dam + (rand(self.str) * rand(self.dam)) / (self.str+self.dam)).to_i
  end

  def self.damage_after_defense(dam, enemy_dfn)
    cdam = (dam - (enemy_dfn + 4 * rand(enemy_dfn)) / 5).to_i
    return (cdam > 0 ? cdam : 0 )
  end

  def self.damage_after_mag_res(mag_dam, int, mag)
    mdam = (mag_dam - rand(int * mag) / 100 - mag - int ).to_i
    return (mdam > 0 ? mdam : 0 )
  end
end
