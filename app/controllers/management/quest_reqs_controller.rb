class Management::QuestReqsController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars
  before_filter :load_quest

  layout 'main'

  #Quest requirments
  def type
    #this will need fixed
    @reqs = SPEC_CODET['quest_req_type']
  end
  
  def new
    new_quest_req_obj
  end
  
  def create
    new_quest_req_obj
    
    if @quest_req.save
      flash[:notice] = 'Requirement saved sucessfully.'
      redirect_to management_quest_path(@quest)
    else
      flash[:notice] = 'Requirement failed to save.'
      render :action => 'new'
    end
  end
  
  def edit
    find_quest_req_obj
  end

  def update
    find_quest_req_obj
    @quest_req.detail = "#{params[:quest_req].try(:[],:npc_division)}:#{params[:quest_req].try(:[],:kingdom_id)}"

    if @quest_req.update_attributes(params[:quest_req])
      flash[:notice] = 'Requirement updated sucessfully.'
      redirect_to management_quest_path(@quest)
    else
      flash[:notice] = 'Requirement failed to update.'
      render :action => 'edit'
    end
  end
  
  def destroy
    find_quest_req_obj
    
    if @quest_req.destroy
      flash[:notice] = 'Destroyed the requirement.'
    else
      flash[:notice] = 'Failed to destroy the requirement.'
    end
    redirect_to management_quest_path(@quest)
  end
  
protected
  def new_quest_req_obj
    if params[:type] == 'creature_kill'
      @quest_req = @quest.creature_kills.build(params[:quest_req])
      @creatures = session[:kingdom].creatures.where(armed: true)
    elsif params[:type] == 'explore'
      @quest_req = @quest.explores.build(params[:quest_req])
      @events = session[:kingdom].event_texts.where(armed: true)
    elsif params[:type] == 'item'
      @quest_req = @quest.items.build(params[:quest_req])
      @items = Item.all
    elsif params[:type] == 'kill_any_npc'
      @quest_req = @quest.kill_n_npcs.build(params[:quest_req])
      @quest_req.detail = "#{params[:quest_req].try(:[],:npc_division)}:#{params[:quest_req].try(:[],:kingdom_id)}"
      @npc_types = [ [SpecialCode.get_code('npc_division','merchant'), 'NpcMerchant'], [SpecialCode.get_code('npc_division','guard'), 'NpcGuard'] ]
      @kingdoms = Kingdom.where('id >= 0').order(:name)
    elsif params[:type] == 'kill_pc'
      @quest_req = @quest.kill_pcs.build(params[:quest_req])
      @pcs = PlayerCharacter.all.order(:name) #might need to add a check for the hardcore to prevent targeting an already final dead char
    elsif params[:type] == 'kill_specific_npc'
      @quest_req = @quest.kill_s_npcs.build(params[:quest_req])
      @npcs = Npc.all.joins(:health).where(
                        ['healths.wellness = ? or healths.wellness = ?',
                        SpecialCode.get_code('wellness','alive'), SpecialCode.get_code('wellness','diseased')]).order(:name)
    else
      flash[:notice] = 'Invalid type!'
      redirect_to type_management_quest_reqs_path(quest: @quest, id: params[:id])
      return
    end  
  end
  
  def find_quest_req_obj
    @quest_req = @quest.reqs.find(params[:id])
    if @quest_req.kind == 'QuestCreatureKill'
      @creatures = session[:kingdom].creatures.where(armed: true)
    elsif @quest_req.kind == 'QuestExplore'
      @events = session[:kingdom].event_texts.where(armed: true)
    elsif @quest_req.kind == 'QuestItem'
      @items = Item.all
    elsif @quest_req.kind == 'QuestKillNNpc'
      @npc_types = [ [SpecialCode.get_code('npc_division','merchant'), 'NpcMerchant'], [SpecialCode.get_code('npc_division','guard'), 'NpcGuard'] ]
      @kingdoms = Kingdom.where('id >= 0').order(:name)
    elsif @quest_req.kind == 'QuestKillPc'
      @pcs = PlayerCharacter.all.order(:name)
    elsif @quest_req.kind == 'QuestKillSNpc'
      @npcs = Npc.all.joins(:health).where(
                        ['healths.wellness = ? or healths.wellness = ?',
                        SpecialCode.get_code('wellness','alive'), SpecialCode.get_code('wellness','diseased')]).order(:name)
    else
      flash[:notice] = 'Invalid type!'
      redirect_to management_quest_path(@quest)
      return
    end
  end

  def load_quest
    @quest = session[:kingdom].quests.find(params[:quest_id])
    if @quest.quest_status != SpecialCode.get_code('quest_status', 'design')
      flash[:notice] = @quest.name + ' cannot be edited; it is already being used.'
      redirect_to management_quest_path(@quest)
      return
    end
  end
end
