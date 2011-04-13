class CreatureKill < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :creature
  
  def self.log_kill(pcid,cid,amount)
    rec = self.find_or_create(pcid, cid)
     rec.transaction do
      rec.lock!
      rec.number += amount
      rec.save!
    end
  end
  
  def self.find_or_create(oid, cid)
    conds = {:player_character_id => oid, :creature_id =>  cid }

    it = find(:first, :conditions => conds)
    return it unless it.nil?

    TableLock.transaction do
      tl = TableLock.find_by_name(self.sti_name, :lock => true)
      it = find(:first, :conditions => conds) || create(conds)
      tl.save!
    end
    return it
  end
end
