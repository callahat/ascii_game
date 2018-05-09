class Admin::NameSurfixesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_name_surfix, only: [:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @name_surfixes = NameSurfix.get_page(params[:page])
  end

  def new
    @name_surfix = NameSurfix.new
  end

  def create
    @name_surfix = NameSurfix.new(name_surfix_params)
    if @name_surfix.save
      flash[:notice] = 'NameSurfixes was successfully created.'
      redirect_to admin_name_surfixes_path
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @name_surfix.update_attributes(name_surfix_params)
      flash[:notice] = 'NameSurfixes was successfully updated.'
      redirect_to admin_name_surfixes_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @name_surfix.destroy
    redirect_to admin_name_surfixes_path
  end

  protected

  def name_surfix_params
    params.require(:name_surfix).permit(:surfix)
  end

  def set_name_surfix
    @name_surfix = NameSurfix.find(params[:id])
  end
end
