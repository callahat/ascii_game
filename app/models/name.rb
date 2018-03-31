class Name < ActiveRecord::Base
  attr_accessible :name

  def self.gen_name
    @parts = rand(6) + 2
    
    #dec                bin
    # 1 - first name    001
    # 2 - middle name   010
    # 4 - last name     100
    #logical OR, if no change, then this name part is valid
    if @parts | 2 == @parts
      @first = Name.offset(rand(Name.count)).first.name + " "
    else
      @first = ""
    end
    #middle names more uncommon
    if @parts | 1 == @parts && (rand > 0.4 || @first == "")
      @middle = Name.offset(rand(Name.count)).first.name + " "
    else
      @middle = ""
    end
    
    if @parts | 4 == @parts
      @last = Name.offset(rand(Name.count)).first.name
      
      if rand > 0.25 #then name gets a surfix
        @surfix = NameSurfix.offset(rand(NameSurfix.count)).first.surfix
        if @surfix[-1..-1] == "-"
          @last = @surfix[0..-2] + @last
        elsif @surfix[0..0] == "-"
          @last = @last + @surfix[1..-1]
        end
      end
      
    else
      @last = ""
    end
    
    @name = @first + @middle + @last
    @name.strip!
    return @name
  end
  
  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 25, :page => page)
  end
end
