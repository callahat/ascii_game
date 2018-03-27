class Game::CourtController < ApplicationController
  before_filter :setup_pc_vars

  layout 'main'

  def throne
    @king_on_throne = @pc.present_kingdom.player_character
  end

  def join_king
    PlayerCharacter.transaction do
      @pc.lock!
      @pc.kingdom_id = @pc.in_kingdom

      flash[:notice] = 'You have joined the ranks of ' + @pc.present_kingdom.player_character.name
      @pc.save!
    end
    render 'game/complete'
  end

  def king_me
    Kingdom.transaction do
      @kingdom = @pc.present_kingdom
      @kingdom.lock!
      @king = @kingdom.player_character
      if @king
        @message = 'King ' + @king.name + ' glowers at your attempt to sit upon his throne.'
        render 'game/complete'
      else
        if @pc.level < 15
          @message = 'The steward approaches "You are yet not strong enough to claim the crown."'
        else
          @kingdom.player_character_id = @pc[:id]
          @message = 'You have claimed the crown'
          KingdomNotice.create_notice(@pc.name + " has found the throne vacant, and claimed it for their own.", @pc.in_kingdom)
        end
        render 'game/complete'
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
end
