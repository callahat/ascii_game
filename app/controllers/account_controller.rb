class AccountController < ApplicationController
  before_filter :authenticate, only: [:show]
  before_filter :set_player, only: [:show]

  layout 'main'

  def show
  end

  def what
  end

  protected

  def set_player
    @player = current_player
  end
end
