module GameHelper
	def battle_grid(battle)
		ret = "<table><tr>\n"
		c = 0
		battle.groups.each{|bg|
			ret += "<td>"
			ret += "<pre class=\"creature\">" + bg.enemies[0].enemy.image.image_text + "</pre>\n"
			ret += submit_tag(bg.name) + "</td>\n"
			ret += "</tr><tr>\n" if c % 5 == 0
			c+=1
		}
		ret + "</tr></table>\n"
	end
	
	def draw_map(where)
		if where.class == Level
			draw_kingdom_map(where)
		else
			draw_world_map(where)
		end
	end
	
#protected
	def draw_kingdom_map(where)
		@ret = "<p><b>" + where.kingdom.name + ", level " + where.level.to_s + "</b></p>\n"
		@ret += "<p>" + link_to('Leave Kingdom', :action => 'leave_kingdom') + "</p>\n" if where.level == 0
		@ret += "<table>"
		0.upto(where.maxy-1){|y|
			@ret += "<tr>\n"
			0.upto(where.maxx-1){|x|
				@ret += "<td>\n"
				level_map = where.level_maps.find(:last,:conditions => ['ypos = ? AND xpos = ?', y, x])
				if level_map && feature = level_map.feature
					@ret += "<span title=\"" + feature.name + "\">" + 
									"<a href=\"/game/feature?id=" + level_map.id.to_s + "\" class=\"map\">" + 
									"<pre class=\"feature\">" + feature.image.image_text + "</pre>\n</a></span>"
				else
					@ret += "<span title=\"Empty\">" + 
									"<a href=\"#\" class=\"map\"><pre class=\"feature\">" +
									EMPTY_IMAGE + "</pre></a></span>"
				end
			}
		}
		return @ret + "</tr>\n</table>\n"
	end
	
	#expects [world, bigx, bigy]
	def draw_world_map(where)
		@ret =	"<table>\n  <tr>\n  <td>X</td>\n  <td align=\"center\">\n"
		if WorldMap.exists?(:bigxpos => where[1], :bigypos => where[2] - 1)
			@ret += link_to('|North|', {:action => 'world_move', :id => 'north'},:method => :post)
		else
			@ret += "North"
		end %
		@ret += "  </td>\n  <td>X</td>\n</tr>\n<tr>\n  <td>\n"
		if WorldMap.exists?(:bigxpos => where[1] - 1, :bigypos => where[2]) 
			@ret += link_to('|W|<br/>|e|<br/>|s|<br/>|t|<br/>', {:action => 'world_move', :id => 'west'},:method => :post)
		else 
			@ret += "W<br/>e<br/>s<br/>t<br/>"
		end
		@ret += "  </td>\n  <td>\n" + world_map_table(where) + "  </td>\n  <td>\n"
		if WorldMap.exists?(:bigxpos => where[1] + 1, :bigypos => where[2])
			@ret += link_to('|E|<br/>|a|<br/>|s|<br/>|t|<br/>', {:action => 'world_move', :id => 'east'},:method => :post)
		else
			@ret += "E<br/>a<br/>s<br/>t<br/>"
		end
		@ret += "  </td>\n</tr>\n<tr>\n  <td>X</td>\n  <td align=\"center\">\n"
		if WorldMap.exists?(:bigxpos => where[1], :bigypos => where[2] + 1)
			@ret += link_to('|South|', {:action => 'world_move', :id => 'south'},:method => :post)
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
				wm = where[0].world_maps.find(:last, :conditions => ['bigypos = ? and bigxpos = ? and ypos = ? and xpos = ?', where[2], where[1], y, x])
				if wm && f = wm.feature
					@ret += "<td><span title=\"" + f.name + "\"<a href=\"/game/feature?id=" +
									wm .id.to_s + "\" class=\"map\">" +
									"<pre class=\"world_feature\">" + f.image.image_text + "</pre>" +
									"</a></span></td>"
				else
					@ret += "<td><span title=\"Empty\"><a href=# class=\"map\">" +
									"<pre class=\"world_feature\">" + EMPTY_IMAGE + "</pre>" +
									"</a></span></td>"
				end
			}
			@ret += "</tr>"
		}
		return @ret += "</table>"
	end
end
