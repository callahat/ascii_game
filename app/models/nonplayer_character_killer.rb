class NonplayerCharacterKiller < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :npc
  
  def self.create_npc_kill_row(killer,npc)
    if killer.class == PlayerCharacter
      #create a player_character_killer row, this will only be updated by the attacker, there should be only one
      #thread for the attacking character.
      @npc_kill = self.new
      @npc_kill.player_character_id = killer.id
      @npc_kill.npc_id = npc.id
      @npc_kill.when = Time.now
      if !@npc_kill.save
        print "\nfailed to save the new pker row!"
      end
    end
  end
  
  #Pagination related stuff
  def self.get_page(page, pcid = nil)
    where(pcid ? ['player_character_id = ?', pcid] : []) \
      .order('"when DESC"') \
      .paginate(:per_page => 20, :page => page)
  end
end
