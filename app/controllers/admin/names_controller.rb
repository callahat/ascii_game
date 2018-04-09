class Admin::NamesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_name, only: [:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @names = Name.get_page(params[:page])
  end

  def new
    @name = Name.new
  end

  def create
    @name = Name.new(name_params)
    if @name.save
      flash[:notice] = 'Name was successfully created.'
      redirect_to admin_names_path
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @name.update_attributes(name_params)
      flash[:notice] = 'Name was successfully updated.'
      redirect_to admin_names_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @name.destroy
    redirect_to admin_names_path
  end

  protected

  def name_params
    params.require(:name).permit(:name)
  end

  def set_name
    @name = Name.find(params[:id])
  end
end
