class PrefList < ActiveRecord::Base
  self.inheritance_column = 'kind'

  belongs_to :kingdom

  def self.add(where,thing)
    self.create(:kingdom_id => where, :thing_id => thing) unless self.exists?(:kingdom_id => where, :thing_id => thing)
  end
  
  def self.drop(where, thing)
    self.destroy_all(:kingdom_id => where, :thing_id => thing)
  end

  #Pagination related stuff
  def self.get_page(page, c, o)
    where(c) \
      .order(o) \
      .paginate(:per_page => 30, :page => page)
  end
end
