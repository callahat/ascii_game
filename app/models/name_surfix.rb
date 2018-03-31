class NameSurfix < ActiveRecord::Base
  attr_accessible :surfix

  #Pagination related stuff
  def self.get_page(page)
    order('surfix').paginate(:per_page => 25, :page => page)
  end
end
