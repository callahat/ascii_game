module ManagementHelper
  def show_kingdom_map(where)
    @ret = "<p><b>Level: </b>#{ @level.level } - <b>Maxx: </b>#{ @level.maxx } - <b>Maxy: </b>#{ @level.maxy }</p>"
    @ret += "<table>"
    0.upto(where.maxy-1){|y|
      @ret += "<tr>\n"
      0.upto(where.maxx-1){|x|
        level_map = where.level_maps.where(ypos: y, xpos: x).last
        if level_map && feature = level_map.feature
          @ret += "<td>\n<span class=\"feature image\" title=\"#{ h(feature.name) }\">#{ h(feature.image.image_text) }</span>\n</td>\n"
        else
          @ret += "<td>\n<pre class=\"feature image\" title=\"Empty\">#{ h(EMPTY_IMAGE) }</span></td>\n"
        end
      }
      @ret += "</tr>\n"
    }
    (@ret + "\n</table>\n").html_safe
  end

  def npc_summary_rows(npcs)
    npcs.inject(""){|ret, npc|
      ret += "  <tr>
    <td>#{ npc.name }</td>
    <td>#{ npc.kind }</td>
    <td>#{ SpecialCode.get_text('wellness', npc.health.wellness) }</td>
    <td>#{ link_to 'Show', management_kingdom_npc_path(id: npc.id) }</td>
    <td>#{ link_to 'Fire', turn_away_management_kingdom_npc_path(id: npc), data: {confirm: 'Are you sure?'}, :method => :post }</td>
  </tr>\n"
    }.html_safe
  end

  def npc_newhire_rows(npcs)
    npcs.inject(""){|ret, npc|
      l = ( npc.kind == "NpcMerchant" ?
              link_to('Assign store', :action => 'assign_store', :id => npc) :
              link_to('Hire', {:action => 'hire_guard', :id => npc },  :method => :post) )
      ret += "  <tr>
    <td>#{ npc.name } - #{ npc.kind }</td>
    <td>#{ link_to 'Show', management_kingdom_npc_path(id: npc) }</td>
    <td>#{ l }</td>
    <td>#{ link_to 'Turn Away', turn_away_management_kingdom_npc_path(id: npc), data: {confirm: 'Are you sure?'}, :method => :post }</td>
  </tr>\n"
    }.html_safe
  end

  def show_merchant_helper(n)
    @ret = ""
    @ret+= "<p><b>healing_sales: </b>#{ n.npc_merchant_detail.healing_sales }</p>\n" if n.npc_merchant_detail.healing_sales.to_i > 0
    @ret+="<p><b>trainer_sales: </b>#{ n.npc_merchant_detail.trainer_sales }</p>" if n.npc_merchant_detail.trainer_sales.to_i > 0
    if n.npc_merchant_detail.blacksmith_sales.to_i > 0
      @ret+="<p><b>blacksmith_sales: </b>#{ n.npc_merchant_detail.blacksmith_sales }</p>\n" +
            "<p><b>race body type: </b>#{ SpecialCode.get_text('race_body_type',n.npc_merchant_detail.race_body_type) }</p>\n" +
            "<p><b>consignor: </b>#{ n.npc_merchant_detail.consignor }</p>\n"
    end
    (@ret += "<p><b>Store Location: </b>" + ((@npc.event_npcs.last and (@loc = @npc.event_npcs.last.level_map)) ?
             "Level #{ @loc.level.level }, #{ @loc.ypos } by #{ @loc.xpos }" : "None" ) + "</p>\n").html_safe
  end

  def show_stats_hepler(n)
    Stat.symbols.inject(""){|ret,at|
      ret += "<p><b>#{ Stat.human_attr(at) }: </b>#{ n.stat[at] }</p>\n" }.html_safe
  end
end
