module GameHelper
  def battle_grid(battle)
    ret = "<table><tr>\n"
    c = 0
    battle.groups.each{|bg|
      ret += "<td>"
      ret += "<span class=\"creature image\">" + h(bg.enemies[0].enemy.image.image_text) + "</span>\n"
      ret += submit_tag(bg.name)
      ret += "</td>\n"
      ret += "</tr><tr>\n" if c % 5 == 0
      c+=1
    }
    return ret + "</tr></table>\n"
  end
  
  def draw_map(where)
    if where.class == Level
      return draw_kingdom_map(where)
    else
      return draw_world_map(where)
    end
  end
  
#protected
  def draw_kingdom_map(where)
    @ret = "<p><b>" + where.kingdom.name + ", level " + where.level.to_s + "</b></p>\n"
    @ret += "<p>" + helper_link_to('Leave Kingdom', :action => 'leave_kingdom') + "</p>\n" if where.level == 0
    @ret += "<table>"
    0.upto(where.maxy-1){|y|
      @ret += "<tr>\n"
      0.upto(where.maxx-1){|x|
        level_map = where.level_maps.where(ypos: y, xpos: x).last
        if level_map && feature = level_map.feature
          @ret += "<td>\n<a href=\"/game/feature?id=" + level_map.id.to_s + "\" class=\"map\">" + 
                  "<span class=\"feature image\" title=\"" + (feature.name.split("::").first) + "\">"  + html_escape(feature.image.image_text) + "</span>\n</a></td>\n"
        else
          @ret += "<td>\n<a href=\"#\" class=\"map\"><pre class=\"feature image\" title=\"Empty\">" +
                  h(EMPTY_IMAGE) + "</span></a></td>\n"
        end
      }
      @ret += "</tr>\n"
    }
    return @ret + "\n</table>\n"
  end
  
  #expects [world, bigx, bigy]
  def draw_world_map(where)
    @ret = "<table>\n  <tr>\n  <td>X</td>\n  <td align=\"center\">\n"
    if WorldMap.exists?(:bigxpos => where[1], :bigypos => where[2] - 1)
      @ret += '<pre>' + helper_link_to("|North|", {:action => 'world_move', :id => 'north'}) + '</pre>'
    else
      @ret += "North"
    end %
    @ret += "  </td>\n  <td>X</td>\n</tr>\n<tr>\n  <td>\n"
    if WorldMap.exists?(:bigxpos => where[1] - 1, :bigypos => where[2]) 
      @ret += '<pre>' + helper_link_to("|W|\n|e|\n|s|\n|t|", {:action => 'world_move', :id => 'west'}) + '</pre>'
    else 
      @ret += "W<br/>e<br/>s<br/>t<br/>"
    end
    @ret += "  </td>\n  <td>\n" + world_map_table(where) + "  </td>\n  <td>\n"
    if WorldMap.exists?(:bigxpos => where[1] + 1, :bigypos => where[2])
      @ret += '<pre>' + helper_link_to("|E|\n|a|\n|s|\n|t|", {:action => 'world_move', :id => 'east'}) + '</pre>'
    else
      @ret += "E<br/>a<br/>s<br/>t<br/>"
    end
    @ret += "  </td>\n</tr>\n<tr>\n  <td>X</td>\n  <td align=\"center\">\n"
    if WorldMap.exists?(:bigxpos => where[1], :bigypos => where[2] + 1)
      @ret += '<pre>' + helper_link_to("|South|", {:action => 'world_move', :id => 'south'}) + '</pre>'
    else
      @ret += "South"
    end
    return @ret + "  </td>\n  <td>X</td>\n</tr>\n</table>\n"
  end
  
  def world_map_table(where)
    @ret = "<table>\n"
    1.upto(where[0].maxy){|y|
      @ret += "<tr>"
      1.upto(where[0].maxx){|x|
        wm = where[0].world_maps.where(bigypos: where[2], bigxpos: where[1], ypos: y, xpos: x).last
        if wm && f = wm.feature
          @ret += "<td><a href=\"/game/feature?id=" + wm.id.to_s + "\" class=\"map\">" +
                  "<span class=\"world_feature image\" title=\"" + h(f.name.split("::").first) + "\">" + h(f.image.image_text) + "</span>" +
                  "</a></td>"
        else
          @ret += "<td><a href=# class=\"map\">" +
                  "<span class=\"world_feature image\" title=\"Empty\">" + h(EMPTY_IMAGE) + "</span>" +
                  "</a></td>"
        end
      }
      @ret += "</tr>"
    }
    return @ret += "</table>"
  end
  
  #overriding this method, its broken at least for unit tests. will undo once Rails3 is fixed. Bug listed at:
  #https://rails.lighthouseapp.com/projects/8994/tickets/6652-cannot-include-actionviewhelpers-and-railsapplicationroutesurl_helpers-at-the-same-time
  def helper_link_to(name, params)
    '<a href="game/'+ params[:action] + (params[:id].nil? ? "" : '/' + params[:id]) + '" >' + name + '</a>'
  end
end
