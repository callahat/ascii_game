module CharacterHelper
  #setup the hidden info, so javascript can take care of putting new info up
  def class_stat_dump(cclasses)
    hiddens = ""
    
    for cclass in cclasses do
      @c_class_stat = cclass.level_zero
    
      @notstats = "<b>Description:</b><br/>" + cclass.description + "<br/>"
      if cclass.attack_spells
        @notstats +=  "+Can use attack spells.<br/>"
      end
      if cclass.healing_spells
        @notstats +=  "+Can use healing spells.<br/>"
      end
      
      hiddens += hidden_input_help("c_class_id", cclass, @notstats)
      hiddens += stat_helps("c_class_id", cclass, @c_class_stat)
    end
    
    return hiddens
  end
  
  def race_stat_dump(races)
    hiddens = ""
    
    for race in races do
      @notstats = "<b>Description:</b><br/>" + race.description + "<br/>"
      
      if !race.kingdom_id.nil?
        @notstats += "<b>Home Kingdom:</b><br/>" + race.kingdom.name + " <br/>"
      end
      @notstats += "<b>Body Type:</b><br/>" + SpecialCode.get_text('race_body_type',race.race_body_type) + "<br/>"
      @race_stat = race.level_zero
      
      hiddens += hidden_input_help("race_id", race, @notstats)
      hiddens += stat_helps("race_id", race, @race_stat)
    end
    return hiddens
  end
  
  def stat_helps(what,who,stat)
    hiddens = hidden_input_help(what,who,stat.str.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.dam.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.dfn.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.dex.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.int.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.mag.to_i.to_s)
    hiddens += hidden_input_help(what,who,stat.con.to_i.to_s)
    hiddens += hidden_input_help(what,who,who.freepts.to_i.to_s)
    return hiddens + hidden_input_help(what,who,stat.total_exp_for_level(1).to_s)
  end
  
  def hidden_input_help(what, who, val)
    '<input type="hidden" class="' + what + ' ' + who.id.to_s + '" value="' + val + '"/>' + "\n"
  end
  
  def freepoint_distributer(foo, bar)
    return '<input type="button" value="-" id="' + foo + '_' + bar + '"/>' + text_field(foo, bar, :size => 2) + '<input type="button" value="+" id="' + foo + '_' + bar + '"/>'
  end

  def character_link_cells character
    if character.char_stat == SpecialCode.get_code('char_stat', 'deleted')
      '<td colspan="4"></td>'.html_safe
    else
      links = [].tap do |str|
        if character.char_stat == SpecialCode.get_code('char_stat', 'active')
          str << link_to('Select', do_choose_character_path(character.id), data: {confirm: 'Are you sure?'}, method: :post)
        else
          str << ''
        end
        str << link_to('Edit Image', do_image_update_character_path(character.id))
        if character.char_stat == SpecialCode.get_code('char_stat', 'retired')
          str << link_to('Unretire', do_unretire_character_path(character.id), data: {confirm: 'Are you sure?'}, method: :post)
        else
          str << link_to('Retire', do_retire_character_path(character.id), data: {confirm: 'Warning: Retiring a character will erase all progress on quests, infections, and items your character has in its inventory.'}, method: :post)
        end
        str << link_to('Destroy', do_destroy_character_path(character.id), data: {confirm: 'Warning: Destroying a character will prevent you from ever playing it again, although history will remember its actions..'}, method: :post)
      end
      links.map{|l| content_tag(:td, l) }.join("\n").html_safe
    end
  end
end
