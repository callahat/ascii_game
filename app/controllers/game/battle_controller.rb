class Game::BattleController < ApplicationController
	before_filter :authenticate

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_choose, :do_train ],				 :redirect_to => { :action => :feature }

	def fight_pc
		@enemy_pc = @pc.current_event.player_character
		@pc = session[:player_character]
		result, msg = Battle.new_pc_battle(@pc, @enemy_pc)

		pre_battle_director(result, msg)
	end

	def fight_npc
		@pc = session[:player_character]
		@npc = @pc.current_event.npc
		result, msg = Battle.new_npc_battle(@pc, @npc)

		pre_battle_director(result, msg)
	end

	def fight_king
		@pc = session[:player_character]
		@kingdom = @pc.present_kingdom
		result, msg = Battle.new_king_battle(@pc, @kingdom)

		pre_battle_director(result, msg)
	end

	def battle
		@battle = Battle.find(:first, :conditions => ['owner_id = ?', session[:player_character][:id]])
		@pc = session[:player_character]

		if @battle.nil?
			redirect_to :controller => '/game', :action => 'main'
		elsif session[:regicide] && session[:keep_fighting].nil?
			session[:keep_fighting] = true
			@pc.present_kingdom.change_king(nil)
			redirect_to :action => 'regicide'
		elsif @booty = @battle.victory
			@message = "The enemy host has been defeated!<br/>Found " + @booty[:gold].to_s + " gold."
			if @pc.in_kingdom
				@message += " Taxman takes " + @booty[:tax].to_s + " of it."
			end
			@pc.current_event.update_attribute(:completed, EVENT_COMPLETED) if @pc.current_event
			@battle.clear_battle
			render 'game/complete'
		elsif @pc.health.HP <= 0
			@message = "You have been killed."
			@battle.clear_battle
			render 'game/complete'
		else #fight on!
			@healing_spells = []
			@attack_spells = []
			if session[:player_character].c_class.healing_spells
				healing_list = HealingSpell.find(:all, :conditions => ['min_level < ?', session[:player_character].level])
				@healing_spells = healing_list.collect() {|s| [s.name + ' (MP:' + s.mp_cost.to_s + ')' , s.id ] }
			end
			if session[:player_character].c_class.attack_spells
				attack_list = AttackSpell.find(:all, :conditions => ['min_level < ?', session[:player_character].level])
				@attack_spells = attack_list.collect() {|s| splash = ( s.splash ? ' (splash)' : '' )
																	[ s.name + ' (MP:' + s.mp_cost.to_s + ' HP:' + s.hp_cost.to_s + ')' + splash , s.id]}
			end
		end
	end

	def fight
		@battle = Battle.find(:first, :conditions => ['owner_id = ?', session[:player_character][:id]])
		@pc = session[:player_character]
	
		@bg = @battle.groups.find_by_name(params[:commit]) if params[:commit] && params[:commit] != ""
		
		session[:attack] = params[:attack]
		session[:attack] = (@spell = AttackSpell.find(params[:attack])).id if params[:commit] !~ /Heal/ && params[:attack] && params[:attack] != ""
		if params[:commit] =~ /Heal/
			@spell = HealingSpell.find(params[:heal])
			session[:heal] = @spell.id
			@bg = @pc 
		end

		@battle.report = {}
		@battle.for_this_round(@pc, @bg, @spell)

		flash[:battle_report] = @battle.report

		redirect_to :action => 'battle'
	end

	def run_away
		@battle = Battle.find(:first, :conditions => ['owner_id = ?', session[:player_character][:id]])
		@pc = session[:player_character]

		if @battle.run_away(75)
			@pc.current_event.update_attribute(:completed, EVENT_FAILED) if @pc.current_event
			@message = 'You ran away.'
			render 'game/complete'
		else
			@message = 'could not run away'
			@battle.for_this_round(@pc, nil)
			flash[:notice] = 'Could not run away'
			flash[:notice] += @battle.report.to_s
			redirect_to :action => 'battle'
		end
	end

	def regicide
		if session[:regicide]
			session[:completed] = true
			@kingdom = session[:player_character].present_kingdom
		else
			redirect_to :controller => '/game', :action => 'feature'
		end
	end
protected
	#In the future, this may not be needed if events leading to battles setup the battle stuff themselves and
	#redirect to the battle action. But for now, here it is.
	def pre_battle_director(result, msg, comp=nil)
		if result
			redirect_to :action => 'battle'
		else
			@message = msg
			session[:completed] = comp
			render 'game/complete'
		end
	end
end
