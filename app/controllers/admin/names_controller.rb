class Admin::NamesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @names = Name.get_page(params[:page])
  end

  def new
    @name = Name.new
  end

  def create
    @name = Name.new(params[:name])
    if @name.save
      flash[:notice] = 'Name was successfully created.'
      redirect_to admin_names_path
    else
      render :action => 'new'
    end
  end

  def edit
    @name = Name.find(params[:id])
  end

  def update
    @name = Name.find(params[:id])
    if @name.update_attributes(params[:name])
      flash[:notice] = 'Name was successfully updated.'
      redirect_to admin_names_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    Name.find(params[:id]).destroy
    redirect_to admin_names_path
  end
end
