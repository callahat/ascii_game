class Admin::NpcsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  before_filter :load_divisions, only: [:new,:create,:edit,:update]

  layout 'admin'

  def index
    @npcs = Npc.get_page(params[:page])
  end

  def show
    @npc = Npc.find(params[:id])
  end

  def new
    @npc = Npc.new_of_kind(params[:npc])
    @npc.image_id = nil
    @npc.build_stat
    @npc.build_health
    @npc.build_image(image_text: Image.first.image_text)
  end

  def create
    @npc = Npc.new_of_kind(params[:npc])
    @npc.image_id = nil
    @npc.image.name = @npc.name + ' Image'
    @npc.image.player_id = session[:player].id
    @npc.image.kingdom_id = Kingdom.find_by(name: 'SystemGeneratd').id
    
    if @npc.save
      NpcMerchant.gen_merch_attribs(@npc).save! if @npc.kind == 'NpcMerchant'

      flash[:notice] = 'Npc was successfully created.'
      redirect_to admin_npc_path(@npc)
    else
      @npc.build_stat
      @npc.build_health
      render :action => 'new'
    end
  end

  def edit
    @npc = Npc.find(params[:id])
  end

  def update
    @npc = Npc.find(params[:id])

    params[:npc].delete(:image_attributes) unless @npc.image.npcs.count == 1

    if @npc.update_attributes(params[:npc])
      flash[:notice] = 'Npc was successfully updated.'
      redirect_to admin_npc_path(@npc)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Npc.find(params[:id]).destroy
    redirect_to admin_npcs_path
  end

  protected

  def load_divisions
    @divisions = [ ['merchant', 'NpcMerchant'],
                   ['guard', 'NpcGuard'] ]
  end
end
