class AdminController < ApplicationController
  def show
    redirect_to admin_attack_spells_path
  end
end
