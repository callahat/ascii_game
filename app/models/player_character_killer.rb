class PlayerCharacterKiller < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :killed_character, :foreign_key => 'killed_id', :class_name => 'PlayerCharacter'
  
  def self.find_killer(id)
    #Find all the rows for all the players this player has killed
    find_by_sql("select * from player_character_killers where player_character_id = #{id}")
  end

  def self.find_specific_kills(p_id,k_id)
    #find the row for the player killed by this player
    find_by_sql("select * from player_character_killers where player_character_id = #{p_id} and killed_id = #{k_id}")
  end
  
  def self.create_pk_row(killer,pc)
    if killer.class == PlayerCharacter
      #create a player_character_killer row, this will only be updated by the attacker, there should be only one
      #thread for the attacking character.
      @pker = self.new
      @pker.player_character_id = killer.id
      @pker.killed_id = pc.id
      @pker.when = Time.now
      if !@pker.save
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
