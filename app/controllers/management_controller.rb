class ManagementController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter
	before_filter :setup_kingdom_vars, :except => ['main_index', 'choose_kingdom', 'select_kingdom']

	layout 'main'
	
#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :do_retire ],				 :redirect_to => { :action => :main_index }
	
	def choose_kingdom
		session[:kingdom] = nil
		redirect_to :action => 'main_index'
	end

	def main_index
		if session[:kingdom].nil? || @pc.nil?
			#code for regular menu to do things
			#Have the player pick a kingdom to manage, they mgith have multiple
			#Kingdoms depending on their characters in play
			#@pcs = PlayerCharacter.find_all(:player_id => session[:player][:id])
			@pcs = session[:player].player_characters
			@kingdoms = Array.new

			#get the kingdoms for the drop down menu
			for pc in @pcs
				@ks=Kingdom.find(:all,:conditions => ['player_character_id = ?', pc.id], :order => 'name')
				if @ks.size > 0 
					for k in @ks
						@kingdoms << k
					end
				end
			end
		end
	end

	def helptext
	end
	
	def select_kingdom
		@kingdom = Kingdom.find(params[:king][:kingdom_id])
		if session[:player].player_characters.find(@kingdom.player_character_id)
			session[:kingdom] = @kingdom
		else
			flash[:notice] = 'You are not the king in the kingdom submitted!'
		end
		redirect_to :action => 'main_index'
	end
	
	def retire
		print "tits"
	 # params[:s][:s]
		if session[:kingdom].nil?
			redirect_to :action => 'retire'
			return
		elsif params[:commit] == "Abandon"
			@no_king = true
			@message = 'Really leave the kingdom without a monarch?'
		elsif params[:new_king]
			print "in here"
			@player_character = PlayerCharacter.find(:first, :conditions => ['name = ?', params[:new_king]])
			session[:new_king] = @player_character
			if @player_character.nil?
				@message = 'No such character by the name "' + params[:new_king] + '" was found.'
			elsif @player_character.kingdom
				@message = 'Really hand the throne over to ' + @player_character.name + ' of ' + @player_character.kingdom.name + '?'
			else
				@message = 'Really hand the throne over to ' + @player_character.name + '?'
			end
		end
	end
	
	def do_retire
		print "Made it to do_retire"
		if params[:commit] == "Cancel"
			session[:new_king] = nil
			redirect_to :action => 'retire'
		else
			if session[:new_king]
				@player_character = PlayerCharacter.find(:first, :conditions => ['name = ?', session[:new_king].name])
			end
			if @player_character.nil?
				@pc_id = nil
				@message = session[:kingdom].player_character.name + " has abandonded their position as king of " + session[:kingdom].name + ", designating no sucessor."
			else
				@pc_id = @player_character.id
				@message = session[:kingdom].player_character.name + " has abdicated rule of " + session[:kingdom].name + " to " + @player_character.name
			end
		
			@kingdom = session[:kingdom]
			@kingdom.player_character_id = @pc_id
		
			if @kingdom.save
				flash[:notice] = 'You have relinquished the crown of ' + @kingdom.name
			
				#New kingdom notice
				KingdomNotice.create_notice(@message, @kingdom.id)
			end
			
			session[:kingdom] = nil
			session[:new_king] = nil
			session[:kingbit] = false
			
			redirect_to :controller => 'game'
		end
	end
	
protected
	def setup_kingdom_vars
		redirect_to :action => 'choose_kingdom' unless @kingdom = session[:kingdom]
	end
end
