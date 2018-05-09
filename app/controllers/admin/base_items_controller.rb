class Admin::BaseItemsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_base_item, only: [:show,:edit,:update,:destroy]
  
  layout 'admin'

  def index
    @base_items = BaseItem.get_page(params[:page])
  end

  def show
  end

  def new
    @base_item = BaseItem.new
  end

  def create
    @base_item = BaseItem.new(base_item_params)
    if @base_item.save
      flash[:notice] = 'BaseItem was successfully created.'
      redirect_to admin_base_item_path(@base_item)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @base_item.update_attributes(base_item_params)
      flash[:notice] = "#{@base_item.name} was successfully updated."
      redirect_to admin_base_item_path(@base_item)
    else
      render :action => 'edit'
    end
  end

  def destroy
    BaseItem.find(params[:id]).destroy
    redirect_to admin_base_items_path
  end

  protected

  def base_item_params
    params.require(:base_item).permit(:name, :description, :equip_loc, :price, :race_body_type)
  end

  def set_base_item
    @base_item = BaseItem.find(params[:id])
  end
end
