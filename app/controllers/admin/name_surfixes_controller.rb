class Admin::NameSurfixesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @name_surfixes = NameSurfix.get_page(params[:page])
  end

  def new
    @name_surfix = NameSurfix.new
  end

  def create
    @name_surfix = NameSurfix.new(params[:name_surfix])
    if @name_surfix.save
      flash[:notice] = 'NameSurfixes was successfully created.'
      redirect_to admin_name_surfixes_path
    else
      render :action => 'new'
    end
  end

  def edit
    @name_surfix = NameSurfix.find(params[:id])
  end

  def update
    @name_surfix = NameSurfix.find(params[:id])
    if @name_surfix.update_attributes(params[:name_surfix])
      flash[:notice] = 'NameSurfixes was successfully updated.'
      redirect_to admin_name_surfixes_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    NameSurfix.find(params[:id]).destroy
    redirect_to admin_name_surfixes_path
  end
end
