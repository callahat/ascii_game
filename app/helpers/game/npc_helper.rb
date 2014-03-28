module Game::NpcHelper
  def disease_cures(pc, diseases_cured, tax_rate)
    @ret = ""
    diseases_cured.each{|disease|
      next unless pc.illnesses.exists?(:disease_id => disease.id)
      @ret += "<tr>\n<td>" +
              link_to('Cure ' + disease.name, npc_do_heal_url(:did => disease.id) ) +
              "</td>\n<td>for " + (Disease.abs_cost(disease)* (1 + tax_rate)).to_i.to_s + " gold</td>\n</tr>\n"
    }
    @ret
  end
end
