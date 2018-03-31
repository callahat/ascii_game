class TrainerSkill < ActiveRecord::Base
  validates_presence_of :max_skill_taught,:min_sales

  attr_accessible :max_skill_taught,:min_sales

  #Pagination related stuff
  def self.get_page(page)
    order('min_sales').paginate(:per_page => 20, :page => page)
  end
end
