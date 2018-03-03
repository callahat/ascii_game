class CharacterseController < ApplicationController
  #before_filter :authenticate
  before_filter :setup_pc_vars

  #figure out caching later. It seems to work faster if the boot file has the cacheing
  #to true, but I can't find a cache of this pages where the books says it should be.
  #caches_page :new2

  layout 'main'

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :do_equip, :unequip ],         :redirect_to => { :action => :inventory }

  def index
    redirect_to :action => 'menu'
  end

  def menu
  end
  
  def attack_spells
    @attack_spells = AttackSpell.get_page(params[:page], @pc.level)
  end
  
  def healing_spells
    @healing_spells = HealingSpell.get_page(params[:page], @pc.level)
  end
  
  def infections
    @infections = Infection.get_page(params[:page], @pc.id)
  end
  
  def pc_kills
    @pc_kills = PlayerCharacterKiller.get_page(params[:page], @pc.id)
  end
  
  def npc_kills
    @npc_kills = NonplayerCharacterKiller.get_page(params[:page], @pc.id)
  end

  def genocides
    @genocides = Genocide.get_page(params[:page], @pc.id)
  end

  def done_quests
    @done_quests = DoneQuest.get_page(params[:page], @pc.id)
  end
  
  def inventory
    @pc_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
    @equip_locs = @pc.player_character_equip_locs.includes(:item)
  end
  
  def equip
    @loc = @pc.player_character_equip_locs.find(params[:id])
    @item = @loc.item
    if @loc.nil?
      flash[:notice] = "Invalid equip location"
      redirect_to :action => 'inventory'
      return
    elsif !@item.nil?
      do_unequip(@pc, @loc.id)
    end
    
    @pc_items = PlayerCharacterItem.get_page(params[:page], @pc.id, @loc.equip_loc)
  end
  
  def do_equip
    equip
    
    @pc_item = @pc.items.find(params[:iid])
  
    if @pc_item.nil?
      flash[:notice] = "You don't have any of those to equip"
      redirect_to :action => 'inventory'
      return
    end
    
    @item = @pc_item.item
    
    if @item.race_body_type != nil && @item.race_body_type != @pc.race.race_body_type
      flash[:notice] = "That item cannot be equipped; you have an incompatible body type"
      redirect_to :action => 'inventory'
      return
    end
    
    if PlayerCharacterItem.update_inventory(@pc.id, @item.id,-1)
      if update_equip_loc(@pc, @loc, @item, 1)
        flash[:notice] = @item.name + " equipped on " + SpecialCode.get_text('equip_loc',@loc.equip_loc)
      else
        print "\nOH NOES FAILED TO UPDATE PLAYER EQUIP LOC/ PLAYER CHAR STATS!"
      end
    else
      flash[:notice] = "Something went wrong when trying to unequip"
    end
    redirect_to :action => 'inventory'
  end
  
  def unequip
    do_unequip(@pc, params[:id])
    redirect_to :action => 'inventory'
  end
  
protected
  def do_unequip(who, where_id)
    @loc = who.player_character_equip_locs.find(where_id)
    @item = @loc.item
    if @loc.nil?
      flash[:notice] = "Invalid equip location"
    elsif @item.nil?
      flash[:notice] = "Nothing to unequip there"
    else
      if PlayerCharacterItem.update_inventory(who.id,@item.id,1)
        if update_equip_loc(who,@loc, @item, -1)
          flash[:notice] = @item.name + " unequipped from " + SpecialCode.get_text('equip_loc',@loc.equip_loc)
          return true
        else
          print "\nOH NOES FAILED TO UPDATE PLAYER EQUIP LOC/ PLAYER CHAR STATS!"
        end
      else
        flash[:notice] = "Something went wrong when trying to unequip"
      end
    end
    return false
  end

  def update_equip_loc(who, where, what, number)
    if number < 0
      print "\nShould lower stats" + what.inspect
      where.item_id = nil
    else
     print "\nShould up stats" + what.inspect
      where.item_id = what.id
    end
    
    if !where.save
      Rails.logger.info "\nFailed to update the player equip loc."
      if !PlayerCharacterItem.update_inventory(who.id,what.id,number)
        Rails.logger.info "\nFailed to update PC inventory after location update failed"
      end
      return false
    end
    
    StatPc.transaction do
      @stat = who.stat
      @stat.lock!
    
      Rails.logger.info "nstr:" + @stat.str.to_s + "\ndex:" + @stat.dex.to_s + "\ncon:" + @stat.con.to_s + "\nint:" + @stat.int.to_s + "\nmag:" + @stat.mag.to_s + "\ndfn:" + @stat.dfn.to_s + "\ndam:" + @stat.dam.to_s + "\n"
      if number > 0
        @stat.add_stats(what.stat)
      else
        @stat.subtract_stats(what.stat)
      end
      Rails.logger.info "nstr:" + @stat.str.to_s + "\ndex:" + @stat.dex.to_s + "\ncon:" + @stat.con.to_s + "\nint:" + @stat.int.to_s + "\nmag:" + @stat.mag.to_s + "\ndfn:" + @stat.dfn.to_s + "\ndam:" + @stat.dam.to_s + "\n"
      @stat.save!
    end
    return true
  end
end
