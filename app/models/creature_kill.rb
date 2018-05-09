class CreatureKill < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :creature
  
  def self.log_kill(pcid,cid,amount)
    rec = self.find_or_create_by(player_character_id: pcid, creature_id: cid)
     rec.transaction do
      rec.lock!
      rec.number += amount
      rec.save!
    end
  end
end
