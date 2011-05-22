module ForumHelper
  def forum_node_statuses(user, forum_node, board=nil, thred=nil)
    mod_level = (user ? user.forum_attribute.mod_level : 0)
    return "" unless mod_level > 1
    [[ :is_locked, 2, "lock"],
     [ :is_hidden, 4, "hide"],
     [ :is_mods_only, 7, "mods_only"],
     [ :is_deleted, 8, "delete"]].inject("") do |str, arr|
      what, level, why = arr
      where = what.to_s[3..-1]
      why = 'un' + why if forum_node[what]
      
      param_hash = { :action => 'toggle_'+where, :forum_node_id => forum_node.id}
      param_hash[:bname] = board.name if board
      param_hash[:tname] = thred.name if thred
  
      str += mod_level > level ?
               " " +link_to("-"+why,  param_hash  ) :
               ""
    end
  end
end
