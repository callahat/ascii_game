class Game::CourtController < ApplicationController
	before_filter :authenticate

	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_choose, :do_train ],				 :redirect_to => { :action => :feature }
	
	def throne
		@king = session[:player_character].present_kingdom.player_character
	end
	
	def join_king
		PlayerCharacter.transaction do 
			@player_character = session[:player_character]
			@player_character.lock!
			@player_character.kingdom_id = session[:player_character].in_kingdom

			flash[:notice] = 'You have joined the ranks of ' + session[:player_character].present_kingdom.player_character.name
		@player_character.save!
		end
		render :action => '../complete'
	end
	
	def king_me
		Kingdom.transaction do 
			@kingdom = session[:player_character].present_kingdom
		@kingdom.lock!
			@king = @kingdom.player_character
			if @king
				@message = 'King ' + @king.name + ' glowers at your attempt to sit upon his throne.'
				render :action => '../complete'
			else
				if session[:player_character].level < 15
					@message = 'The steward approaches "You are yet not strong enough to claim the crown."'
					render :action => '../complete'
				else
					@kingdom.player_character_id = session[:player_character][:id]
					@message = 'You have claimed the crown'
					create_accession_notice(session[:player_character].name + " has found the throne vacant, and claimed it for their own.", session[:player_character].present_kingdom)
				end
				render :action => '../complete'
			end
		@kingdom.save!
		end
	end
	
	def castle
		@kingdom = session[:player_character].present_kingdom
	end
	
	def bulletin
		# step 1: read and set the variables you'll need
		page = (params[:page] ||= 1).to_i
		notices_per_page = 10
		offset = (page - 1) * notices_per_page

		
		# step 2: do your custom find without doing any kind of limits or offsets
		#	i.e. get everything on every page, don't worry about pagination yet
		if session[:player_character][:id] == session[:player_character].present_kingdom.player_character_id
			#if king
			@notices = session[:player_character].present_kingdom.kingdom_notices
		elsif session[:player_character].kingdom_id == session[:player_character].in_kingdom
			#if ally
			@notices = session[:player_character].present_kingdom.kingdom_notices.find(:all, :conditions => ['shown_to = ? OR shown_to = ?', SpecialCode.get_code('shown_to','everyone'),SpecialCode.get_code('shown_to','allies')])
		else #if a passer by
			@notices = session[:player_character].present_kingdom.kingdom_notices.find(:all, :conditions => ['shown_to = ?', SpecialCode.get_code('shown_to','everyone')])
		end

		# step 3: create a Paginator, the second variable has to be the number of ALL items on all pages
		@notice_pages = Paginator.new(self, @notices.length, notices_per_page, page)

		# step 4: only send a subset of @items to the view
		# this is where the magic happens... and you don't have to do another find
		@notices = @notices[offset..(offset + notices_per_page - 1)]
	end
	
	
	
	def use_stairs
		#move the player
	PlayerCharacter.transaction do
		session[:player_character].lock!
	
			@event = Feature.find(:first, :conditions => ['name = ?', "\nCastle #{session[:player_character].present_kingdom.name}"]).feature_events.find(:first, :conditions => ['event_id = ?', params[:id]])

			if @event
				@event_move = @event.event.event_move
			
				session[:player_character][:kingdom_level] = @event_move.move_id
				session[:player_character].save
				@message = "You moved to level " + @event_move.level.level.to_s
			
				session[:completed] = true
			else
				@message = "You cannot move there"
			end
			session[:player_character].save!
		end

		render :action => '../complete'
	end
	
	def quest_office
		#list the active quests of the kingdom
		@allquests = session[:player_character].present_kingdom.quests.find(:all, :include => 'log_quests', :conditions => ['quests.quest_status = ? OR (quests.id = log_quests.quest_id and log_quests.player_character_id = ? and log_quests.completed = true)', SpecialCode.get_code('quest_status','active'), session[:player_character][:id]], :order => 'quest_status')
		
		@quests = []
		print "\n"
		for q in @allquests
		print "\n" + q.name
			if q.quest_id.nil?
				@quests << q
			elsif session[:player_character].done_quests.exists?(:quest_id => q.quest_id)
				@quests << q
			end
		end
	end
	
	def view_quest
		@quest = session[:player_character].present_kingdom.quests.find(:first, :conditions => ['id = ?', params[:qid]])
		@done_quest = @quest.done_quests.find(:first, :conditions => ['player_character_id = ?', session[:player_character][:id]])
		if @quest.quest_status == SpecialCode.get_code('quest_status','design')
			redirect_to :action => 'quest_office'
		end
		
		@times_completed = LogQuest.find(:all, :conditions => ['quest_id = ? and completed = ?', @quest.id, true]).size
		@log_quest = session[:player_character].log_quests.find(:first, :conditions => ['quest_id = ?', @quest.id])
		
		if @log_quest
			@reqs_remaining = @log_quest.reqs.size
		
			for quest_item in @quest.items
				@pc_inv = session[:player_character].items.find(:first, :conditions => ['item_id = ?', quest_item.detail])
				if @pc_inv
					@pc_inv = @pc_inv.quantity
				else
					@pc_inv = 0
				end
				@diff = (quest_item.quantity - @pc_inv) 
				if quest_item.quantity - @pc_inv > 0
					@reqs_remaining += 1
				end
			end
		
			if @reqs_remaining == 0 && session[:player_character].done_quests.find(:first, :conditions => ['quest_id = ?', @quest.id]).nil?
				@log_quest.completed = true
				@log_quest.save
			
				#create done quest
				@done_quest = DoneQuest.new
				@done_quest.quest_id = @quest.id
				@done_quest.player_character_id = session[:player_character][:id]
				@done_quest.date = Time.now
				if !@done_quest.save
					print "\nFailed to save done quest!"
				end
			end
		end
		session[:viewing_quest] = @quest
	end
	
	def join_quest
		#verify the player is eligible for th quest, they are not already signed up, they have not completed ti already,
		#and the quest is still active and completeable
		
		joined, msg = LogQuest.join_quest(session[:player_character], params[:qid])
		
		if joined
		flash[:notice] = "You have taken an oath to pursue the quest"
		redirect_to :action => 'view_quest', :qid => params[:qid]
		else
			flash[:notice] = msg
			redirect_to :action => 'quest_office'
		end
	end
		
	def abandon_quest
		abandoned, msg = LogQuest.abandon(session[:player_character], params[:qid])
		
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
			@log_quest = @quest.log_quests.find(:first, :conditions => ['player_character_id = ?', session[:player_character][:id]])
			
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
			
			@reward_item = @quest.item
			@kingdom = session[:player_character].present_kingdom
			
			if @reward_item
				@kingdom_item = KingdomItem.find(:first, :conditions => ['kingdom_id = ? and item_id = ?', @kingdom.id, @reward_item.id])
			
				if @kingdom_item.nil?
					flash[:notice] = "There are no reward items. Check back later."
					return
				else
					if !KingdomItem.update_inventory(@kingdom.id,@reward_item.id,-1)
						flash[:notice] = "The reward item is out of stock. Check back later"
						redirect_to :action => 'view_quest', :qid => @quest.id
						return
					end
				end
			end
			
		Kingdom.transaction do
			@kingdom = session[:player_character].present_kingdom
			
				@quest.gold = @quest.gold.to_i
			
				if @kingdom.gold < @quest.gold
					flash[:notice] = "There is not enough gold in the coffers to pay your reward! Try collecting later."
					@kingdom.save!
				
					if @reward_item #reutrn the item
						KingdomItem.update_inventory(@kingdom.id,@reward_item.id,1)
					end
					redirect_to :action => 'view_quest', :qid => @quest.id
					return
				else
					if @quest.gold > 0
						@kingdom.gold -= @quest.gold
						@kingdom.save!
				
						PlayerCharacter.transaction do
							session[:player_character].lock!
							session[:player_character].gold += @quest.gold
				session[:player_character].save!
						end
					end
				
					PlayerCharacterItem.update_inventory(session[:player_character].id,@reward_item.id,1) if @reward_item
					flash[:notice] = "You collected the reward"
				
					@log_quest.rewarded = true
					@log_quest.save
				end
		end
			redirect_to :action => 'view_quest', :qid => @quest.id
		else
			redirect_to :action => 'quest_office'
		end
	end
end