class HomeController < ApplicationController
	before_filter :authenticate

	layout 'main'
	
	def index
		@player = session[:player]
		if @player
			@actives = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code('char_stat','active')])
			@retireds = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code('char_stat','retired')])
			@deads = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code('char_stat','final death')])
		end
	end
end
