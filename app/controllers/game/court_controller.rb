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
				else
					@kingdom.player_character_id = @pc[:id]
					@message = 'You have claimed the crown'
					KingdomNotice.create_notice(@pc.name + " has found the throne vacant, and claimed it for their own.", @pc.present_kingdom)
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
end