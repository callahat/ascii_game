class Inventory < ActiveRecord::Base
  self.inheritance_column = 'kind'
  
  belongs_to :item

  validates_presence_of :quantity,:owner_id,:item_id
  
  def self.validate
    if !quantity.nil? && quantity < 0
      errors.add("quantity","cannot be negative")
      return false
    end
  end
  
  def self.update_inventory(oid,iid,amount)
    inv = self.find_or_create(oid, iid)
    inv.transaction do
      inv.lock!
      if inv.quantity < (-1) * amount
        return inv.save! && false
      else
        inv.quantity += amount
        return inv.save!
      end
    end
  end
  
  def self.find_or_create(oid, iid)
    conds = {:owner_id => oid, :item_id =>  iid }

    it = find(:first, :conditions => conds)
    return it unless it.nil?
  
    TableLock.transaction do
      tl = TableLock.find_by_name(self.sti_name, :lock => true)
      it = find(:first, :conditions => conds) || create(conds)
      tl.save!
    end
    return it
  end
  
  #Pagination related stuff
  def self.per_page
    25
  end
  
  def self.get_page(page, oid = nil, rbt = nil)
    conds = ['quantity > 0']

    if oid
      conds[0] += ' and owner_id = ?'
      conds << oid
    end
    if rbt
      conds[0] += ' and (items.race_body_type is null or items.race_body_type = ?)'
      conds << rbt
    end

    joins('INNER JOIN items on inventories.item_id = items.id')\
      .where(conds)                                            \
      .order('items.name')                                     \
      .paginate(:per_page => 25, :page => page)
  end
end
