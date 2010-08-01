module ManagementHelper
	def show_kingdom_map(where)
		@ret = "<p><b>Level: </b>#{ @level.level } - <b>Maxx: </b>#{ @level.maxx } - <b>Maxy: </b>#{ @level.maxy }</p>"
		@ret += "<table>"
		0.upto(where.maxy-1){|y|
			@ret += "<tr>\n"
			0.upto(where.maxx-1){|x|
				level_map = where.level_maps.find(:last,:conditions => ['ypos = ? AND xpos = ?', y, x])
				if level_map && feature = level_map.feature
					@ret += "<td>\n<span class=\"feature image\" title=\"#{ h(feature.name) }\">#{ h(feature.image.image_text) }</span>\n</td>\n"
				else
					@ret += "<td>\n<pre class=\"feature image\" title=\"Empty\">#{ h(EMPTY_IMAGE) }</span></td>\n"
				end
			}
			@ret += "</tr>\n"
		}
		return @ret + "\n</table>\n"
	end
	
	def edit_kingdom_map(where)
		@ret = "<table>"
		0.upto(where.maxy-1){ |y|
			@ret += "<tr>\n"
			0.upto(where.maxx-1){ |x|
				@ret += "<td>\n"
				square = where.level_maps.find(:all, :conditions => ['ypos = ? and xpos = ?', y, x]).last.feature
				if square.nil? || square.name == "\nEmpty"
					@ret += "<select name=\"map[#{ y }][#{ x }]\" style=\"width:9em\">\n" +
									"	<option value = \"\"></option>\n	" +
									"	#{ options_from_collection_for_select(@features, 'id','name') }\n"
				elsif square.name[0..0] == "\n"
					@ret += h(square.name[1..12]) + ( square.name[13..13] ? "..." : "" ) +
									"<hidden value=\"#{ square.id }\" name=\"map[#{ y }][#{ x }]\">\n"
				else
					@ret += "<select name=\"map[#{ y }][#{ x }]\" style=\"width:9em\">\n" +
									"	<option value = \"\">#{ (square ? "("+square.name+")" : "" ) }</option>\n" +
									"	#{ options_from_collection_for_select(@features,'id','name', nil ) }\n"
				end
			@ret += "</td>\n"
			}
		@ret += "</tr>\n"
		}
		@ret + "</table>\n"
	end
end
