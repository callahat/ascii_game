class Game::NpcController < ApplicationController
  before_filter :setup_pc_vars
  before_filter :setup_npc_vars
  before_filter :spread_contact_disease, :only => [:do_train, :do_buy, :do_buy_new, :do_sell ]

  layout 'main'

  def npc
    Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','air'))
    Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','air'))
  end
  
  def smithy
    redirect_to npc_game_npc_path and return unless (@can_make = @npc.npc_blacksmith_items).size > 0
  end
  
  def do_buy_new
    smithy
    
    res, msg = @npc.manufacture(@pc, params[:iid])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    
    redirect_to smithy_game_npc_path
  end

  def heal
    redirect_to npc_game_npc_path and return unless (@npc_healer_skills = @npc.npc_merchant_detail.healer_skills.includes(:disease)).size > 0

    @diseases_cured = @npc_healer_skills.collect{|cure| cure.disease }.compact

    @max_HP_heal = @npc.max_heal(@pc, "HP")
    @max_HP_heal_cost = (MiscMath.point_recovery_cost(@max_HP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
    @max_MP_heal = @npc.max_heal(@pc, "MP")
    @max_MP_heal_cost = (MiscMath.point_recovery_cost(@max_MP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
  end

  def do_heal
    heal

    if params[:did]
      _res, @msg = @npc.cure_disease(@pc, params[:did].to_i)
    elsif params[:HP]
      _res, @msg = @npc.heal(@pc, "HP")
    elsif params[:MP]
      _res, @msg = @npc.heal(@pc, "MP")
    else
      @msg = 'Do what now?'
    end
    flash[:notice] = @msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )

    redirect_to heal_game_npc_path
  end
 
  def train
    redirect_to npc_game_npc_path and return unless (@max_skill = @npc.npc_merchant_detail.max_skill_taught) > 0
    @atrib = Stat.new(train_atrib_params)

    @cost_per_pt = (@pc.level * 10 * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
  end
  
  def do_train
    train
    res, msg = @npc.train(@pc, @atrib)
    
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    if res
      redirect_to train_game_npc_path
    else
      render :action => 'train'
    end
  end
  
  def buy
    redirect_to npc_game_npc_path and return unless @npc.npc_merchant_detail.consignor
    @stocks = NpcStock.get_page(params[:page], @npc.id).includes(:item)
  end
  
  def do_buy
    res, msg = @npc.sell_used_to(@pc, params[:id])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    redirect_to buy_game_npc_path
  end
  
  def sell
    redirect_to npc_game_npc_path and return unless @npc.npc_merchant_detail.consignor
    @player_character_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
  end
  
  def do_sell
    res, msg = @npc.buy_from(@pc, params[:id])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    redirect_to sell_game_npc_path
  end
  
protected
  def setup_npc_vars
    redirect_to feature_game_path unless @pc.current_event && @pc.current_event.event.class == EventNpc
    @event = @pc.current_event.event
    @npc = @event.npc
    
    unless @npc.health.HP > 0 && @npc.health.wellness != SpecialCode.get_code('wellness','dead')
      @pc.current_event.destroy
      flash[:notice] = @npc.name + " has shuffled from this mortal coil"
      redirect_to main_game_path
    end
  end

  def spread_contact_disease
    Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact'))
    Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact'))
  end

  def train_atrib_params
    if params[:atrib]
      params.require(:atrib).permit(:str, :dex, :con, :int, :mag, :dfn, :dam)
    else
      {}
    end
  end
end
