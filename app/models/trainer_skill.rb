class TrainerSkill < ActiveRecord::Base
  validates_presence_of :max_skill_taught,:min_sales
  
  #Pagination related stuff
  def self.per_page
    10
  end
  
  def self.get_page(page)
    paginate(:page => page, :order => 'min_sales' )
  end
end
