class Admin::ItemsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_item, only: [:show,:edit,:update,:destroy]

  layout 'admin'

  def index
    @items = Item.get_page(params[:page])
  end

  def show
  end

  def new
    @item = Item.new
    @item.build_stat
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      flash[:notice] = 'Item was successfully created.'
      redirect_to [:admin,@item]
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @item.update_attributes(item_params)
      flash[:notice] = 'Item was successfully updated.'
      redirect_to [:admin,@item]
    else
      render :action => 'edit'
    end
  end

  def destroy
    if !@item.in_use? && @item.destroy
      flash[:notice] = "Destroyed #{@item.name}"
    else
      flash[:notice] = "Could not destroy #{@item.name}"
    end

    redirect_to admin_items_path
  end

  protected

  def item_params
    params.require(:item).permit(
        :name,
        :equip_loc,
        :description,
        :base_item_id,
        :min_level,
        :c_class_id,
        :race_id,
        :race_body_type,
        :price,
        # :npc_id,
        stat_attributes: [:str, :dex, :con, :int, :mag, :dfn, :dam])
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
