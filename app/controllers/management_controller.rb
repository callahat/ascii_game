class ManagementController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'
	
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_retire ],				 :redirect_to => { :action => :index }
	
	def choose_kingdom
		session[:kingdom] = nil
		redirect_to :action => 'index'
	end

	def index
		if session[:kingdom].nil? || session[:player_character].nil?
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
		redirect_to :action => 'index'
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
			@pc = PlayerCharacter.find(:first, :conditions => ['name = ?', params[:new_king]])
			session[:new_king] = @pc
			if @pc.nil?
				@message = 'No such character by the name "' + params[:new_king] + '" was found.'
			elsif @pc.kingdom
				@message = 'Really hand the throne over to ' + @pc.name + ' of ' + @pc.kingdom.name + '?'
			else
				@message = 'Really hand the throne over to ' + @pc.name + '?'
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
				@pc = PlayerCharacter.find(:first, :conditions => ['name = ?', session[:new_king].name])
			end
			if @pc.nil?
				@pc_id = nil
				@message = session[:kingdom].player_character.name + " has abandonded their position as king of " + session[:kingdom].name + ", designating no sucessor."
			else
				@pc_id = @pc.id
				@message = session[:kingdom].player_character.name + " has abdicated rule of " + session[:kingdom].name + " to " + @pc.name
			end
		
			@kingdom = session[:kingdom]
			@kingdom.player_character_id = @pc_id
		
			if @kingdom.save
				flash[:notice] = 'You have relinquished the crown of ' + @kingdom.name
			
				#New kingdom notice
				KingdomNotice.create_accession_notice(@message, @kingdom.id)
			end
			
			session[:kingdom] = nil
			session[:new_king] = nil
		
			redirect_to :controller => '/management'
		end
	end
end
