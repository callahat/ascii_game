class Admin::ItemsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  layout 'admin'

  def index
    @items = Item.get_page(params[:page])
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
    @item.build_stat
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      flash[:notice] = 'Item was successfully created.'
      redirect_to [:admin,@item]
    else
      render :action => 'new'
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:item])
      flash[:notice] = 'Item was successfully updated.'
      redirect_to [:admin,@item]
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])
    if !@item.in_use? && @item.destroy
      flash[:notice] = "Destroyed #{@item.name}"
    else
      flash[:notice] = "Could not destroy #{@item.name}"
    end

    redirect_to admin_items_path
  end
end
