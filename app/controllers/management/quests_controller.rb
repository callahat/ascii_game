class Management::QuestsController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars
  before_filter :set_kingdom

  layout 'main'

  #**********************************************************************
  #QUEST MANAGEMENT
  #**********************************************************************
  def index
    #design quest
    #@quests = session[:kingdom].quests
    @quests = Quest.get_page(params[:page], session[:kingdom][:id])
  end
  
  def show
    @quest = @kingdom.quests.find(params[:id])

    #Get the requirements for completion of the quest
    @quest_creature_kills = @quest.creature_kills
    @quest_explores = @quest.explores
    @quest_items = @quest.items
    @quest_kill_n_npcs = @quest.kill_n_npcs
    @quest_kill_pcs = @quest.kill_pcs
    @quest_kill_s_npcs = @quest.kill_s_npcs
  end

  def new
    @quest = @kingdom.quests.new
    @prereqs = @kingdom.quests.where(quest_status: SpecialCode.get_code('quest_status','active'))
    setup_reward_items
  end

  def create
    @quest = @kingdom.quests.new(quest_params)
    @prereqs = @kingdom.quests.where(quest_status: SpecialCode.get_code('quest_status','active'))
    setup_reward_items
    
    @quest.player_id = current_player.id
    @quest.quest_status = SpecialCode.get_code('quest_status','design')
    
    if @quest.save
      flash[:notice] = @quest.name + ' created.'
      redirect_to :action => 'show', :id => @quest
    else
      flash[:notice] = 'The quest was not created.'
      render :action => 'new'
    end
  end

  def edit
    @quest = @kingdom.quests.find(params[:id])
    @prereqs = @kingdom.quests.where(quest_status: SpecialCode.get_code('quest_status','active'))
    setup_reward_items
  end

  def update
    @quest = @kingdom.quests.find(params[:id])
    @prereq = @kingdom.quests.find_by(quest_id: params[:quest][:quest_id])
    @prereqs = @kingdom.quests.where(quest_status: SpecialCode.get_code('quest_status','active'))
    unless verify_quest_not_in_use(@quest)
      redirect_to :action => 'index'
      return
    end

    setup_reward_items
    
    if @quest.update_attributes(quest_params)
      flash[:notice] = @quest.name + ' was updated successfully.'
      redirect_to :action => 'show', :id => params[:id]
    else
      flash[:notice] = 'The quest failed to update.'
      render :action => 'edit'
    end
  end

  #Make the quest available to players
  def activate
    @quest = @kingdom.quests.find(params[:id])
    
    if @kingdom.quests.where(quest_status: '1').size > 16
      flash[:notice] = 'A kingdom can have only 16 active quests at a time.'
    elsif @quest.reqs.size == 0
      flash[:notice] = "Quest must have at least one requirement in order to be activated"
    else
      @quest.quest_status = SpecialCode.get_code('quest_status','active')
      quest_status_change_update
    end
    redirect_to :action => 'index', :page => params[:page]
  end

  #retire a quest/remove it from play entirely
  def retire
    @quest = @kingdom.quests.find(params[:id])
    
    @quest.quest_status = SpecialCode.get_code('quest_status','retired')
    quest_status_change_update
    redirect_to :action => 'index', :page => params[:page]
  end

  #destroy quest. This can only be done if it has never been activated.
  def destroy
    @quest = @kingdom.quests.find(params[:id])
    unless verify_quest_not_in_use(@quest)
      redirect_to :action => 'index', :page => params[:page]
      return
    end
        
    @quest.reqs.each{|r| r.destroy}    
      flash[:notice] = 'Deleted all requirements.<br/>'
    
    if @quest.destroy
      flash[:notice] += 'Destroyed the quest.'
      redirect_to :action => 'index', :page => params[:page]
    else
      flash[:notice] += 'Failed to destroy the quest.'
      redirect_to :action => 'show', :id => params[:id]
    end
  end

protected
  def quest_status_change_update
    if @quest.save
      flash[:notice] = 'Quest status updated to "' + SpecialCode.get_text('quest_status',@quest.quest_status) + '".'
    else
      flash[:notice] = 'Failed to update quest status.'
    end
  end
  
  def setup_reward_items
    @kingdom_items = session[:kingdom].kingdom_items
    @items = []
    
    for ki in @kingdom_items
      @items << ki.item
    end
  end
  
  def verify_quest_not_in_use(quest)
    if @quest.quest_status != SpecialCode.get_code('quest_status','design')
      flash[:notice] = @quest.name + ' cannot be edited; it is already being used.'
      false
    else
      true
    end
  end

  def quest_params
    params.require(:quest).permit(:name, :description, :player_id, :max_level, :max_completeable, :quest_status, :gold, :item_id, :quest_id)
  end

  def set_kingdom
    @kingdom = session[:kingdom]
  end
end
