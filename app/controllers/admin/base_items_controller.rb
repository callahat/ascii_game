class Admin::BaseItemsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  
  layout 'admin'

  def index
    @base_items = BaseItem.get_page(params[:page])
  end

  def show
    @base_item = BaseItem.find(params[:id])
  end

  def new
    @base_item = BaseItem.new
  end

  def create
    @base_item = BaseItem.new(params[:base_item])
    if @base_item.save
      flash[:notice] = 'BaseItem was successfully created.'
      redirect_to admin_base_item_path(@base_item)
    else
      render :action => 'new'
    end
  end

  def edit
    @base_item = BaseItem.find(params[:id])
  end

  def update
    @base_item = BaseItem.find(params[:id])
    if @base_item.update_attributes(params[:base_item])
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
end
