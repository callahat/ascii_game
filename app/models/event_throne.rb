class EventThrone < EventLifeNeutral
  def make_happen(who)
    @king = who.present_kingdom.player_character
    if @king && @king.health.HP > 0 && @king.health.wellness != SpecialCode.get_code('wellness','dead')
      return {:controller => 'game/court', :action => 'throne'}, EVENT_COMPLETED, ""
    else
      return {:controller => 'game/court', :action => 'throne'}, EVENT_COMPLETED, ""
    end
  end
  
  def completes(who)
    #Did they kill the king and accept the crown?
    #Have to have killed the king within ten minute ago
    if PlayerCharacterKiller.where(['killed_id = ? and player_character_id =? and created_at > ?',
                                                  who.present_kingdom.player_character_id,
                                                  who.id,
                                                  Time.now - 10.minutes]).last
      Kingdom.transaction do
        who.present_kingdom.lock!
        who.present_kingdom.player_character_id = who.id
        who.present_kingdom.save!
      end
      KingdomNotice.create_coup_notice(who.name, who.in_kingdom)
    end
  end
  
  def as_option_text(pc=nil)
    "Approach the throne of the king"
  end
end
