class Game::QuestsController < ApplicationController
	before_filter :setup_pc_vars
	before_filter :setup_quest
	before_filter :verify_quest_log, :only => [:do_complete, :do_reward]

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	#really aren't forms being posted, just links followed, and verified against the session that
	#the links are valid to be followed at that time
	#verify :method => :post, :only => [ :do_join ], :redirect_to => { :action => :index }

	def index
		( @log_quest && @log_quest.completed && @log_quest.rewarded ?
			@pc.current_event.update_attribute(:completed, EVENT_COMPLETED) :
			@pc.current_event.update_attribute(:completed, EVENT_FAILED)     )
	end
	
	def do_join
		LogQuest.join_quest(@pc, @quest.id) unless @log_quest
		@message = "You take an oath to pursue the Quest"
		render :file => 'game/complete.rhtml', :layout => true
	end
	
	def do_decline
		@message = "You decline the quest. Perhaps it is too much for you."
		render :file => 'game/complete.rhtml', :layout => true
	end
	
	def do_complete
		if @log_quest.complete_quest
			p "Failed to complete the quest for some reason"
			redirect_to do_reward_quest_url()
		else
			p "Completed the quest"
			redirect_to :action => 'index'
		end
	end
	
	def do_reward
		res, msg = @log_quest.collect_reward
		flash[:notice] = msg
		if res
			@pc.current_event.update_attribute(:completed, EVENT_COMPLETED)
		end
		redirect_to :action => 'index'
	end
protected
	def setup_quest
		redirect_to game_feature_url() unless @pc.current_event.event.class == EventQuest
		@event = @pc.current_event.event
		@quest = @event.quest
		@log_quest = @pc.log_quests.find(:first, :conditions => ['quest_id = ?', @quest.id])
	end
	
	def verify_quest_log
		redirect_to :action => 'index' unless @log_quest
	end
end