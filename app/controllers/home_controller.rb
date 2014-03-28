class HomeController < ApplicationController
  #before_filter :authenticate

  layout 'main'
  
  def index
    if @player = session[:player]
      @actives = @player.player_characters.where(['char_stat = ?', SpecialCode.get_code('char_stat','active')])
      @retireds = @player.player_characters.where(['char_stat = ?', SpecialCode.get_code('char_stat','retired')])
      @deads = @player.player_characters.where(['char_stat = ?', SpecialCode.get_code('char_stat','final death')])
    end
  end
end
