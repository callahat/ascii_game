module GameHelper
	def battle_grid(battle)
		ret = "<table><tr>\n"
		c = 0
		@battle.groups.each{|bg|
			ret += "<td>"
			ret += "<pre class=\"creature\">" + bg.enemies[0].enemy.image.image_text + "</pre>\n"
			ret += submit_tag(bg.name) + "</td>\n"
			ret += "</tr><tr>\n" if c % 5 == 0
			c+=1
		}
		ret + "</tr></table>\n"
	end
end
