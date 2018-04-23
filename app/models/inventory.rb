class Inventory < ActiveRecord::Base
  self.inheritance_column = 'kind'
  
  belongs_to :item

  validates_presence_of :quantity,:owner_id,:item_id
  validates_uniqueness_of :item_id, scope: [:kind, :owner_id]
  
  def self.validate
    if !quantity.nil? && quantity < 0
      errors.add("quantity","cannot be negative")
      return false
    end
  end
  
  def self.update_inventory(oid,iid,amount)
    inv = begin
      self.find_or_create_by(owner_id: oid, item_id: iid)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      Rails.logger.warn "Retrying Inventory.update_inventory find_or_create_by due to race"
      Rails.logger.warn "params: owner_id: #{oid} item_id: #{iid} kind: #{self.class}"
      retry
    end

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
  
  #Pagination related stuff
  def self.get_page(page, oid = nil, equip_loc = nil)
    conds = ['quantity > 0']

    if oid
      conds[0] += ' and owner_id = ?'
      conds << oid
    end
    if equip_loc
      conds[0] += ' and (items.equip_loc is null or items.equip_loc = ?)'
      conds << equip_loc
    end

    joins('INNER JOIN items on inventories.item_id = items.id')\
      .where(conds)                                            \
      .order('items.name')                                     \
      .paginate(:per_page => 25, :page => page)
  end
end
