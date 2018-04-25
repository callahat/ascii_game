class HomeController < ApplicationController
  layout 'main'
  
  def index
    if @player = current_player
      @actives = @player.player_characters.active
      @retireds = @player.player_characters.retired
      @deads = @player.player_characters.dead
    end
  end
end
