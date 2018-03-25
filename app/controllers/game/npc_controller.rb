class Game::NpcController < ApplicationController
  #before_filter :authenticate
  before_filter :setup_pc_vars
  before_filter :setup_npc_vars
  before_filter :spread_contact_disease, :only => [:do_train, :do_buy, :do_buy_new, :do_sell ]

  layout 'main'

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :do_train ], :redirect_to => { :action => :npc }
  
  def npc
    Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','air'))
    Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','air'))
  end
  
  def smithy
    redirect_to npc_index_url and return() unless (@can_make = @npc.npc_blacksmith_items).size > 0
  end
  
  def do_buy_new
    smithy
    
    res, msg = @npc.manufacture(@pc, params[:iid])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    
    redirect_to npc_smithy_url
  end

  def heal
    redirect_to npc_index_url() and return() unless (@npc_healer_skills = @npc.npc_merchant_detail.healer_skills).size > 0

    @diseases_cured = @npc_healer_skills.collect{|cure| cure.disease }.compact

    @max_HP_heal = @npc.max_heal(@pc, "HP")
    @max_HP_heal_cost = (MiscMath.point_recovery_cost(@max_HP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
    @max_MP_heal = @npc.max_heal(@pc, "MP")
    @max_MP_heal_cost = (MiscMath.point_recovery_cost(@max_MP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
  end

  def do_heal
    heal

    if params[:did]
      res, @msg = @npc.cure_disease(@pc, params[:did].to_i)
    elsif params[:HP]
      res, @msg = @npc.heal(@pc, "HP")
    elsif params[:MP]
      res, @msg = @npc.heal(@pc, "MP")
    else
      @msg = 'Do what now?'
    end
    flash[:notice] = @msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )

    redirect_to npc_heal_url()
  end
 
  def train
    redirect_to npc_index_url() and return() unless (@max_skill = @npc.npc_merchant_detail.max_skill_taught) > 0
    @atrib = Stat.new(params[:atrib])
    
    @cost_per_pt = (@pc.level * 10 * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
  end
  
  def do_train
    train
    res, msg = @npc.train(@pc, @atrib)
    
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    if res
      redirect_to npc_train_url()
    else
      render :action => 'train'
    end
  end
  
  def buy
    redirect_to npc_index_url() and return() unless @npc.npc_merchant_detail.consignor
    @stocks = NpcStock.get_page(params[:page], @npc.id)
  end
  
  def do_buy
    res, msg = @npc.sell_used_to(@pc, params[:id])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    redirect_to npc_buy_url()
  end
  
  def sell
    redirect_to npc_index_url() and return() unless @npc.npc_merchant_detail.consignor
    @player_character_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
  end
  
  def do_sell
    res, msg = @npc.buy_from(@pc, params[:id])
    flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
    redirect_to npc_sell_url()
  end
  
protected
  def setup_npc_vars
    redirect_to game_feature_url() unless @pc.current_event && @pc.current_event.event.class == EventNpc
    @event = @pc.current_event.event
    @npc = @event.npc
    
    unless @npc.health.HP > 0 && @npc.health.wellness != SpecialCode.get_code('wellness','dead')
      @pc.current_event.destroy
      flash[:notice] = @npc.name + " has shuffled from this mortal coil"
      redirect_to game_main_url()
    end
  end

  def spread_contact_disease
    Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact'))
    Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact'))
  end
end
