class Management::KingdomNpcsController < ManagementController
  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :hire_merchant, :hire_guard, :turn_away ],         :redirect_to => { :action => :list }

  def list
    @merchs = @kingdom.merchants.joins(:health).order('healths.wellness')
    @guards = @kingdom.guards.joins(:health).order('healths.wellness')
    @npcs_for_hire = @kingdom.npcs.joins(:health) \
                         .where(is_hired: false)  \
                         .where.not(healths: { wellness: SpecialCode.get_code('wellness','dead')} )
  end

  def show
    @npc = @kingdom.npcs.find(params[:id])
  end

  def assign_store
    @npc = @kingdom.hireable_merchants.find(params[:id])
    if @kingdom.kingdom_empty_shops.size == 0
      flash[:notice] = 'No available storefronts for the merchants.'
      redirect_to :action => 'list'
    elsif @npc.is_hired
      flash[:notice] = 'This merchant already has a shop!'
      redirect_to :action => 'list'
    else
      @shops = @kingdom.kingdom_empty_shops
    end
  end
  
  #Hire a guard
  def hire_guard
    @npc = @kingdom.hireable_guards.find(params[:id])
    @npc.update_attribute(:is_hired, true)
    redirect_to :action => 'list'
  end
  
  #revisit this when storefront is set.
  def hire_merchant
    @npc = @kingdom.hireable_merchants.find(params[:id])
    if (params[:level_map].nil? || params[:level_map][:id] == "") && @kingdom.kingdom_empty_shops.first
      @empty = @kingdom.kingdom_empty_shops.first
    elsif @kingdom.kingdom_empty_shops.exists?(params[:level_map][:id])
      @empty = @kingdom.kingdom_empty_shops.find(params[:level_map][:id])
    else
      flash[:notice] = 'No store found for the NPC to set up shop.'
      redirect_to :action => 'list'

      return false
    end
    @level_map = @empty.level_map
    @empty.destroy
    
    @event = EventNpc.generate(@npc.id, @level_map.id)
    FeatureEvent.spawn_gen(
        :feature_id => @level_map.feature_id,
        :event_id => @event.id )
      
    #THAT KINGDOM STORE IS NO LONGER EMPTY
    @npc.update_attribute(:is_hired, true)
    @kingdom.reload
    redirect_to :action => 'list'
  end

  def turn_away
    @npc = @kingdom.npcs.find(params[:id])

    if @npc.is_hired && @npc.kind == "NpcMerchant"
      #PUT THAT STOREFRONT BACK INTO CIRCULATION
      @kingdom_empty_shop = KingdomEmptyShop.create(
          :kingdom_id => @kingdom.id,
          :level_map_id => @npc.event_npcs.last.level_map_id )
      
      @npc.update_attribute(:is_hired, false)
      @npc.event.feature_events.destroy_all
      @npc.event.destroy 
    end
    
    @npc.update_attributes(:kingdom_id => nil, :is_hired => false)
    
    redirect_to :action => 'list'
  end
end
