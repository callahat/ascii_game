class RaceLevel < ActiveRecord::Base
  belongs_to :race

  validates_presence_of :level, :str, :dex, :con, :int, :mag, :dfn, :dam, :freepts
  
  class LevelStatValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.nil?
        record.errors[attribute] << "cannot be null."
      elsif value <= 0
        points = 0
      
        if record[:str].nil?
          record.errors[:str] << "cannot be null."
        elsif record[:str] < 0
          record.errors[:str] << "cannot be less than zero."
        else
          points += record[:str]
        end

        if record[:con].nil?
          record.errors[:con] << "cannot be null."
        elsif record[:con] < 0
          record.errors[:con] << "cannot be less than zero."
        else
          points += record[:con]
        end
        
        if record[:dex].nil?
          record.errors[:dex] << "cannot be null."
        elsif record[:dex] < 0
          record.errors[:dex] << "cannot be less than zero."
        else
          points += record[:dex]
        end

        if record[:mag].nil?
          record.errors[:mag] << "cannot be null."
        elsif record[:mag] < 0
          record.errors[:mag] << "cannot be less than zero."
        else
          points += record[:mag]
        end

        if record[:dam].nil?
          record.errors[:dam] << "cannot be null."
        elsif record[:dam] < 0
          record.errors[:dam] << "cannot be less than zero."
        else
          points += record[:dam]
        end

        if record[:int].nil?
          record.errors[:int] << "cannot be null."
        elsif record[:int] < 0
          record.errors[:int] << "cannot be less than zero."
        else
          points += record[:int]
        end

        if record[:dfn].nil?
          record.errors[:dfn] << "cannot be null."
        elsif record[:dfn] < 0
          record.errors[:dfn] << "cannot be less than zero."
        else
          points += record[:dfn]
        end

        if record[:freepts].nil?
          record.errors[:freepts] << "cannot be null."
        elsif record[:freepts] < 0
          record.errors[:freepts] << "cannot be less than zero."
        else
          points += record[:freepts]
        end

        if level >= 0
          if points < 30 || points > 80
            record.errors[""] << "Attribute points must be between 30 and 80. (Current = " + points.to_s + ")"
          end
        end

        if record.errors[attribute].size > 0 ||
            record.errors[:str].size > 0 ||
            record.errors[:con].size > 0 ||
            record.errors[:dex].size > 0 ||
            record.errors[:dam].size > 0 ||
            record.errors[:dfn].size > 0 ||
            record.errors[:int].size > 0 ||
            record.errors[:mag].size > 0 ||
            record.errors[:freepts].size > 0 
          return false
        else
          return true
        end
      end
    end
  end

  validates :level, :level_stat => true



  #race is passed in as a parameter
  def self.next_level(r, l)
    find_by_sql("select * from race_levels where #{r} = race_id and #{l} + 1 = level") 
  end
  def self.current_level(r, l)
    find_by_sql("select * from race_levels where #{r} = race_id and #{l} = level") 
  end


  def self.xp_cost(mod)
    @xp_cost = mod.to_i * 3
    if mod.nil? || @xp_cost <= 0
      0
    elsif @xp_cost<= 10
      @xp_cost * 2
    elsif @xp_cost <= 100
      (@xp_cost-10) * 4 + 20
    else
      (@xp_cost-100) * (@xp_cost-100) + 380
    end
  end

  def self.mod_level_bonus(level,basemod)
    if level <= 0
      basemod
    elsif level < 10
      basemod / 10.0
    elsif level < 100
      basemod / 10.0 + (level/20).floor
    else
      basemod / 10.0 + (level/15).floor
    end
  end

  def self.equip_loc_xp(r)
    @locs = RaceEquipLoc.where(race_id: r.id).count
    num_equip_loc_xp(@locs)
  end

  def self.num_equip_loc_xp(n)
    #up to 10 equip locations with no XP penalty
    3.power!(n-11).floor*10
  end
end
