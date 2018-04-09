class Admin::NpcsController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_npc, only: [:show,:edit,:update,:destroy]

  before_filter :load_divisions, only: [:new,:create,:edit,:update]

  layout 'admin'

  def index
    @npcs = Npc.get_page(params[:page])
  end

  def show
  end

  def new
    @npc = Npc.new_of_kind(npc_params)
    @npc.image_id = nil
    @npc.build_stat
    @npc.build_health
    @npc.build_image(image_text: Image.first.image_text)
  end

  def create
    @npc = Npc.new_of_kind(npc_params)
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
  end

  def update
    params[:npc].delete(:image_attributes) unless @npc.image.npcs.count == 1

    if @npc.update_attributes(npc_params.tap{ |cp|
                                cp[:image_attributes].merge!(
                                    id: @npc.image_id,
                                    name: @npc.image.name,
                                    player_id: @npc.image.player_id,
                                    kingdom_id: @npc.image.kingdom_id
                                ) if cp[:image_attributes]})
      flash[:notice] = 'Npc was successfully updated.'
      redirect_to admin_npc_path(@npc)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @npc.destroy
    redirect_to admin_npcs_path
  end

  protected

  def load_divisions
    @divisions = [ ['merchant', 'NpcMerchant'],
                   ['guard', 'NpcGuard'] ]
  end

  def npc_params
    if params[:npc]
      params.require(:npc).permit(
          :name,
          :kingdom_id,
          :gold,
          :experience,
          :is_hired,
          :kind,
          health_attributes: [:wellness, :HP, :MP, :base_HP, :base_MP],
          image_attributes: [:image_text, :public, :picture, :image_type],
          stat_attributes: [:str, :dex, :con, :int, :mag, :dfn, :dam],
          npc_merchant_detail_attributes: [:healing_sales,:blacksmith_sales,:trainer_sales,:consignor,:race_body_type]
      )
    else
      {}
    end
  end

  def set_npc
    @npc = Npc.find(params[:id])
  end
end
