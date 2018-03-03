class BlacksmithSkill < ActiveRecord::Base
  belongs_to :base_item

  def self.find_base_items(sales, last_min_sales, rbt=nil)
    @cond_array = ['min_sales <= ? and min_sales > ?', sales, last_min_sales]
    if rbt
      @cond_array[0] += ' and (base_items.race_body_type is null or base_items.race_body_type = ?)'
      @cond_array << rbt
    end
    all.joins(:base_item).where(@cond_array).order(:min_sales)
  end

  validates_presence_of :min_sales,:base_item_id
  
  #Pagination related stuff
  def self.get_page(page)
    order('min_sales').paginate(:per_page => 30, :page => page )
  end
end
