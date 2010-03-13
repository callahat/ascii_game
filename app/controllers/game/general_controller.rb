class Game::GeneralController < ApplicationController
	before_filter :authenticate
	before_filter :pc_alive
	
	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_spawn ], :redirect_to => { :controller => :game, :action => :main }
	
	def spawn_kingdom
		@kingdom = Kingdom.new
	end
	
	def do_spawn
		@wm = session[:last_action]
		
		@kingdom, @msg = Kingdom.spawn(session[:player_character], @wm, params[:kingdom][:name])
		
		if @kingdom
			render :action => 'spawn'
		else
			flash[:notice] = @msg
			redirect_to :controller => '/game', :action => 'complete'
		end
		
		session[:completed] = true
		redirect_to :controller => '/game', :action => 'complete'
	end
end
