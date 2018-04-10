class NameSurfix < ActiveRecord::Base
  #Pagination related stuff
  def self.get_page(page)
    order('surfix').paginate(:per_page => 25, :page => page)
  end
end
