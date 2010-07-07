class Management::QuestsController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'
	
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update, :create_req, :update_req, :destroy_req, :activate, :retire ],				 :redirect_to => { :action => :index }


	#**********************************************************************
	#QUEST MANAGEMENT
	#**********************************************************************
	public
	def index
		#design quest
		#@quests = session[:kingdom].quests
		@quests = Quest.get_page(params[:page], session[:kingdom][:id])
	end
	
	def show
		@quest = Quest.find(params[:id])

		#Get the requirements for completion of the quest
		@quest_creature_kills = @quest.creature_kills
		@quest_explores = @quest.explores
		@quest_items = @quest.items
		@quest_kill_n_npcs = @quest.kill_n_npcs
		@quest_kill_pcs = @quest.kill_pcs
		@quest_kill_s_npcs = @quest.kill_s_npcs
	end

	def new
		@quest = Quest.new
		@prereqs = session[:kingdom].quests.find(:all, :conditions => ['quest_status = ?', SpecialCode.get_code('quest_status','active')])
		setup_reward_items
	end

	def create
		@quest = Quest.new(params[:quest])
		@prereqs = session[:kingdom].quests.find(:all, :conditions => ['quest_status = ?', SpecialCode.get_code('quest_status','active')])
		setup_reward_items
		
		if @quest.quest && !verify_quest_owner(@quest.quest)
			redirect_to :action => 'index'
			return
		end
		
		@quest.player_id = session[:player][:id]
		@quest.kingdom_id = session[:kingdom][:id]
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
		@quest = Quest.find(params[:id])
		@prereqs = session[:kingdom].quests.find(:all, :conditions => ['quest_status = ?', SpecialCode.get_code('quest_status','active')])
		setup_reward_items
	end

	def update
		@quest = Quest.find(params[:id])
		@prereq = Quest.find(:first, :conditions => ['quest_id = ?', params[:quest][:quest_id]])
		@prereqs = session[:kingdom].quests.find(:all, :conditions => ['quest_status = ?', SpecialCode.get_code('quest_status','active')])
		if !verify_quest_owner(@quest) || !verify_quest_not_in_use(@quest) || 
			 (@prereq && !verify_quest_owner(@prereq))
			redirect_to :action => 'index'
			return
		end

		setup_reward_items
		
		if @quest.update_attributes(params[:quest])
			flash[:notice] = @quest.name + ' was updated successfully.'
			redirect_to :action => 'show', :id => params[:id]
		else
			flash[:notice] = 'The quest failed to update.'
			render :action => 'edit'
		end
	end

	#Make the quest available to players
	def activate
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest)
			redirect_to :action => 'index'
			return
		end
		
		if session[:kingdom].quests.find(:all, :conditions => ['quest_status = ?', '1']).size > 16
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
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest)
			redirect_to :action => 'index', :page => params[:page]
			return
		end
		
		@quest.quest_status = SpecialCode.get_code('quest_status','retired')
		quest_status_change_update
		redirect_to :action => 'index', :page => params[:page]
	end

	#destroy quest. This can only be done if it has never been activated.
	def destroy
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest) || !verify_quest_not_in_use(@quest)
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
	
	#Quest requirments
	def add_req
		#this will need fixed
		@reqs = SPEC_CODET['quest_req_type']
	end
	
	def new_req
		@quest = Quest.find(params[:id])
		
		new_quest_req_obj
	end
	
	def create_req
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest) || !verify_quest_not_in_use(@quest)
			redirect_to :action => 'index'
			return
		end
		
	new_quest_req_obj
		
		@quest_req.quest_id = params[:id]
		
		if @quest_req.save
			flash[:notice] = 'Requirement saved sucessfully.'
			redirect_to :action => 'show', :id => params[:id]
		else
			flash[:notice] = 'Requirement failed to save.'
			render :action => 'new_req'
		end
	end
	
	def edit_req
		@quest = Quest.find(params[:id])
		
		find_quest_req_obj
	end
		
	
	def update_req
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest) || !verify_quest_not_in_use(@quest)
			redirect_to :action => 'index'
			return
		end
		
		find_quest_req_obj
		
		if @quest_req.update_attributes(params[:quest_req])
			flash[:notice] = 'Requirement updated sucessfully.'
			redirect_to :action => 'show', :id => params[:id]
		else
			flash[:notice] = 'Requirement failed to update.'
			render :action => 'edit_req'
		end
	end
	
	def destroy_req
		@quest = Quest.find(params[:id])
		if !verify_quest_owner(@quest) || !verify_quest_not_in_use(@quest)
			redirect_to :action => 'index'
			return
		end
		
		find_quest_req_obj
		
		if @quest_req.destroy
			flash[:notice] = 'Destroyed the requirement.'
		else
			flash[:notice] = 'Failed to destroy the requirement.'
		end
		redirect_to :action => 'show', :id => params[:id]
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
	
	def new_quest_req_obj
		if params[:type] == 'creature_kill'
			@quest_req = QuestCreatureKill.new(params[:quest_req])
			@creatures = session[:kingdom].creatures
		elsif params[:type] == 'explore'
			@quest_req = QuestExplore.new(params[:quest_req])
			@events = session[:kingdom].event_texts.find(:all, :conditions => ['armed = true'])
		elsif params[:type] == 'item'
			@quest_req = QuestItem.new(params[:quest_req])
			@items = Item.find(:all)
		elsif params[:type] == 'kill_any_npc'
			@quest_req = QuestKillNNpc.new(params[:quest_req])
			@npc_types = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'npc_division'])
			@kingdoms = Kingdom.find(:all,:order => 'name')
		elsif params[:type] == 'kill_pc'
			@quest_req = QuestKillPc.new(params[:quest_req])
			@pcs = PlayerCharacter.find(:all,:order => 'name') #might need to add a check for the hardcore to prevent targeting an already final dead char
		elsif params[:type] == 'kill_specific_npc'
			@quest_req = QuestKillSNpc.new(params[:quest_req])
			@npcs = Npc.find(:all, :include => :health,
												:conditions => ['healths.wellness = ? or healths.wellness = ?',
												SpecialCode.get_code('wellness','alive'), SpecialCode.get_code('wellness','diseased')],:order => 'name')
		else
			flash[:notice] = 'Invalid type!'
			redirect_to :action => 'show',:id => params[:id]
		end	
	end
	
	def find_quest_req_obj
		@quest_req = QuestReq.find(params[:req_id])
		if @quest_req.kind == 'QuestCreatureKill'
			@creatures = session[:kingdom].creatures
		elsif @quest_req.kind == 'explore'
			@events = session[:kingdom].events.find(:all, :conditions => ['event_type = ?', SpecialCode.get_code('event_type','quest')])
		elsif @quest_req.kind == 'QuestItem'
			@items = Item.find(:all)
		elsif @quest_req.kind == 'QuestKillNNpc'
			@npc_types = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'npc_division'])
			@kingdoms = Kingdom.find(:all,:order => 'name')
		elsif @quest_req.kind == 'QuestKillPc'
			@pcs = PlayerCharacter.find(:all,:order => 'name')
		elsif @quest_req.kind == 'QuestKillSNpc'
			@npcs = Npc.find(:all, :include => :health,
												:conditions => ['healths.wellness = ? or healths.wellness = ?',
												SpecialCode.get_code('wellness','alive'), SpecialCode.get_code('wellness','diseased')],:order => 'name')
		else
			flash[:notice] = 'Invalid type!'
			redirect_to :action => 'show',:id => params[:id]
		end
	end
	
	def verify_quest_owner(quest)
		#if someone tries to edit a feature not belonging to them
		if quest.kingdom_id != session[:kingdom][:id]
			flash[:notice] = 'An error occured while retrieving ' + quest.name
			false
		else
			true
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
end
