class NameTitle < ActiveRecord::Base
  def self.get_title(con, dam, dex, dfn, int, mag, str)
    #get the average
    @stat_hash = Hash.new
    @stat_hash[:con] = con
    @stat_hash[:dam] = dam
    @stat_hash[:dex] = dex
    @stat_hash[:dfn] = dfn
    @stat_hash[:int] = int
    @stat_hash[:mag] = mag
    @stat_hash[:str] = str
    
    @stat_array = @stat_hash.values
    @avg = @stat_array.sum / @stat_array.size.to_f
    
    #print "\n AVG:" + @avg.to_s + " min " + @stat_array.min.to_s + " max " + @stat_array.max.to_s + "\n" + @stat_array.inspect + "\n" + @stat_hash.inspect + "\n" + @stat_hash.values.inspect
    
    #if max and min are within 15% of the average, then use the all title for the avg
    if @stat_array.min >= (@avg * 0.85) && (@stat_array.max <= @avg * 1.15)
      return NameTitle.where(['points <= ?', @avg]).find_by(stat: "all").order("points DESC").title
    end
    
    #otherwise find the max (if several are max, randomly pick one)
    @max_stat = []
    @max_val = 0
    
    for pair in @stat_hash
      if pair[1] == @max_val
        @max_stat << pair[0].to_s
      elsif pair[1] > @max_val
        @max_stat = [pair[0].to_s]
        @max_val = pair[1]
      end
    end
    
    return NameTitle.where(stat: @max_stat.sample).order("points DESC").find_by(['points <= ?', @max_val]).title
  end
  
  #Pagination related stuff
  def self.get_page(page)
    order('stat,points,title').paginate(:per_page => 20, :page => page)
  end
end
