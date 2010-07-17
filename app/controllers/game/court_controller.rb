class Game::CourtController < ApplicationController
	#before_filter :authenticate
	before_filter :setup_pc_vars

	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_choose, :do_train ],				 :redirect_to => { :action => :feature }
	
	def throne
		@king = @pc.present_kingdom.player_character
	end
	
	def join_king
		PlayerCharacter.transaction do 
			@pc.lock!
			@pc.kingdom_id = @pc.in_kingdom

			flash[:notice] = 'You have joined the ranks of ' + @pc.present_kingdom.player_character.name
			@pc.save!
		end
		render :action => '../complete'
	end
	
	def king_me
		Kingdom.transaction do 
			@kingdom = @pc.present_kingdom
			@kingdom.lock!
			@king = @kingdom.player_character
			if @king
				@message = 'King ' + @king.name + ' glowers at your attempt to sit upon his throne.'
				render :action => '../complete'
			else
				if @pc.level < 15
					@message = 'The steward approaches "You are yet not strong enough to claim the crown."'
					render :action => '../complete'
				else
					@kingdom.player_character_id = @pc[:id]
					@message = 'You have claimed the crown'
					create_accession_notice(@pc.name + " has found the throne vacant, and claimed it for their own.", @pc.present_kingdom)
				end
				render :action => '../complete'
			end
		@kingdom.save!
		end
	end
	
	def castle
		@kingdom = @pc.present_kingdom
	end
	
	def bulletin
		@notices = KingdomNotice.get_page(params[:page], @pc, @pc.present_kingdom)
	end
	
	def use_stairs
		#move the player
		PlayerCharacter.transaction do
			@pc.lock!
	
			@event = Feature.find(:first, :conditions => ['name = ?', "\nCastle #{@pc.present_kingdom.name}"]).feature_events.find(:first, :conditions => ['event_id = ?', params[:id]])

			if @event
				@event_move = @event.event.event_move
				@pc.kingdom_level = @event_move.move_id
				@message = "You moved to level " + @event_move.level.level.to_s
				session[:completed] = true
			else
				@message = "You cannot move there"
			end
			@pc.save!
		end

		render :action => '../complete'
	end
	
	def quest_office
		#list the active quests of the kingdom
		@allquests = @pc.present_kingdom.quests.find(:all, :include => 'log_quests', :conditions => ['quests.quest_status = ? OR (quests.id = log_quests.quest_id and log_quests.player_character_id = ? and log_quests.completed = true)', SpecialCode.get_code('quest_status','active'), @pc.id], :order => 'quest_status')
		
		@quests = []
		print "\n"
		for q in @allquests
		print "\n" + q.name
			if q.quest_id.nil?
				@quests << q
			elsif @pc.done_quests.exists?(:quest_id => q.quest_id)
				@quests << q
			end
		end
	end
	
	def view_quest
		@quest = @pc.present_kingdom.quests.find(:first, :conditions => ['id = ?', params[:qid]])
		@done_quest = @quest.done_quests.find(:first, :conditions => ['player_character_id = ?', @pc.id])
		
		@times_completed = LogQuest.find(:all, :conditions => ['quest_id = ? and completed = ?', @quest.id, true]).size
		@log_quest = @pc.log_quests.find(:first, :conditions => ['quest_id = ?', @quest.id])
		
		if @log_quest && !@log_quest.completed
			@log_quest.items.each{|lqi| lqi.complete_req }
			@log_quest.complete_quest
		end
		session[:viewing_quest] = @quest
	end
	
	def join_quest
		#verify the player is eligible for th quest, they are not already signed up, they have not completed ti already,
		#and the quest is still active and completeable
		
		joined, msg = LogQuest.join_quest(@pc, params[:qid])
		
		if joined
			flash[:notice] = "You have taken an oath to pursue the quest"
			redirect_to :action => 'view_quest', :qid => params[:qid]
		else
			flash[:notice] = msg
			redirect_to :action => 'quest_office'
		end
	end
		
	def abandon_quest
		abandoned, msg = LogQuest.abandon(@pc, params[:qid])
		
		if abandoned
			flash[:notice] = "You have abandoned the pursuit of the quest."
			redirect_to :action => 'view_quest', :qid => params[:qid]
		else
			flash[:notice] = msg
			redirect_to :action => 'quest_office'
		end
	end

	def collect_reward
		if session[:viewing_quest]
			@quest = session[:viewing_quest]
			@log_quest = @quest.log_quests.find(:first, :conditions => ['player_character_id = ?', @pc.id])
			
			if @log_quest.nil?
				redirect_to :action => 'view_quest', :qid => @quest.id
				return
			elsif @log_quest.rewarded
				flash[:notice] = "You have already collected the reward for this quest"
				redirect_to :action => 'view_quest', :qid => @quest.id
				return
			elsif !@log_quest.completed
				flash[:notice] = "You have not completed all the requirements for this quest"
				redirect_to :action => 'view_quest', :qid => @quest.id
				return
			end
			
			unless @log_quest.collect_reward
				flash[:notice] = "There is not enough gold in the coffers to pay your reward! Try collecting later."
				redirect_to :action => 'view_quest', :qid => @quest.id
				return
			end
			flash[:notice] = "You collected the reward"
			redirect_to :action => 'view_quest', :qid => @quest.id
		else
			redirect_to :action => 'quest_office'
		end
	end
end