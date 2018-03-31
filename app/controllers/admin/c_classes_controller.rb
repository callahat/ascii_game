class Admin::CClassesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @c_classes = CClass.get_page(params[:page])
  end

  def show
    @c_class = CClass.find(params[:id])
  end

  def new
    @c_class = CClass.new
    @c_class.build_level_zero
  end

  def create
    @c_class = CClass.new(params[:c_class])
    if @c_class.save
      flash[:notice] = 'CClass was successfully created.'
      redirect_to [:admin,@c_class]
    else
      render :action => 'new'
    end
  end

  def edit
    @c_class = CClass.find(params[:id])
  end

  def update
    @c_class = CClass.find(params[:id])
    if @c_class.update_attributes(params[:c_class])
      flash[:notice] = 'CClass was successfully updated.'
      redirect_to [:admin,@c_class]
    else
      render :action => 'edit'
    end
  end

  def destroy
    if CClass.find(params[:id]).destroy
      flash[:notice] = 'Character class destroyed.'
    else
      flash[:notice] = 'Character class was not destroyed.'
    end

    redirect_to admin_c_classes_path
  end
end
