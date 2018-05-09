class Admin::CClassesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_c_class, only: [:show,:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @c_classes = CClass.get_page(params[:page])
  end

  def show
  end

  def new
    @c_class = CClass.new
    @c_class.build_level_zero
  end

  def create
    @c_class = CClass.new(c_class_params)
    if @c_class.save
      flash[:notice] = 'CClass was successfully created.'
      redirect_to [:admin,@c_class]
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @c_class.update_attributes(c_class_params)
      flash[:notice] = 'CClass was successfully updated.'
      redirect_to [:admin,@c_class]
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @c_class.destroy
      flash[:notice] = 'Character class destroyed.'
    else
      flash[:notice] = 'Character class was not destroyed.'
    end

    redirect_to admin_c_classes_path
  end

  protected

  def c_class_params
    params.require(:c_class).permit(
        :name, :description, :attack_spells, :healing_spells, :freepts,
        level_zero_attributes: [:str, :dex, :con, :int, :mag, :dfn, :dam])
  end

  def set_c_class
    @c_class = CClass.find(params[:id])
  end
end
