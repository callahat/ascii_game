class AdminController < ApplicationController
  def index
    redirect_to :controller => '/admin/attack_spells', :action => 'index'
  end
end
