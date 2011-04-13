class Genocide < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :creature
  
  def self.create_genocide_row(player_character_id, pc_level, creature_id, how)
    @genocide = Genocide.new
    @genocide.player_character_id = player_character_id
    @genocide.level = pc_level
    @genocide.when = Time.now
    @genocide.creature_id = creature_id
    @genocide.how_eliminated = SpecialCode.get_text('how_eliminated',how)
    if !@genocide.save
      print "\nGenocide failed to save!" + @genocide.display
    end
  end
  
  #Pagination related stuff
  def self.get_page(page, pcid = nil)
    joins("INNER JOIN creatures on genocides.creature_id = creatures.id") \
      .where( pcid ? ['player_character_id = ?', pcid] : []) \
      .order('creatures.name') \
      .paginate(:per_page => 20, :page => page)
  end
end
