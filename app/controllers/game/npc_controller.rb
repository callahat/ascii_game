class Game::NpcController < ApplicationController
	#before_filter :authenticate
	before_filter :setup_pc_vars
	before_filter :setup_npc_vars
	before_filter :spread_contact_disease, :only => [:do_train, :do_buy, :do_buy_new, :do_sell ]

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_buy, :do_train, :do_buy_new, :do_sell ], :redirect_to => { :action => :npc }
	
	def npc
		Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','air'))
		Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','air'))
	end
	
	def smithy
		redirect_to(:action => 'npc') and return() unless @can_make = @npc.npc_blacksmith_items
	end
	
	def do_buy_new
		smithy
		
		res, msg = @npc.manufacture(@pc, params[:iid])
		flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
		
		redirect_to :action => 'smithy'
	end

	def heal
		@npc_healer_skills = @npc.npc_merchant_detail.healer_skills 
		
		@diseases_cured = @npc_healer_skills.collect{|cure| cure.disease }.compact

		@max_HP_heal = @npc.max_heal(@pc, "HP")
		@max_HP_heal_cost = (MiscMath.point_recovery_cost(@max_HP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		@max_MP_heal = @npc.max_heal(@pc, "MP")
		@max_MP_heal_cost = (MiscMath.point_recovery_cost(@max_MP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
	end

	def do_heal
		heal

		if params[:did]
			res, @msg = @npc.cure_disease(@pc, params[:did])
		elsif params[:HP]
			res, @msg = @npc.heal(@pc, "HP")
		elsif params[:MP]
			res, @msg = @npc.heal(@pc, "MP")
		else
			@msg = 'Do what now?'
		end
		flash[:notice] = @msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )

		redirect_to :action => 'heal'
	end
 
	def train
		@max_skill = @npc.npc_merchant_detail.max_skill_taught
		@atrib = Stat.new(params[:atrib])
		
		@cost_per_pt = (@pclevel * 10 * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		@flag = false
	end
	
	def do_train
		train
		res, msg = @npc.train(@pc, @attrib)
		flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
		if res
			redirect_to :action => 'train'
		else
			render :action => 'train'
		end
	end
	
	def buy
		@stocks = NpcStock.get_page(params[:page], @npc.id)
	end
	
	def do_buy
		res, msg = @npc.sell_used_to(@pc, params[:id])
		flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
		redirect_to :action => 'buy'
	end
	
	def sell
		@player_character_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
	end
	
	def do_sell
		@player_character_item = @pc.items.find(:first, :conditions => ['id = ?', params[:id]])
	
		if @player_character_item && PlayerCharacterItem.update_inventory(@pc.id,@player_character_item.item_id,-1)
			NpcStock.update_inventory(@npc.id,@player_character_item.item_id,1)
			@cost = (@player_character_item.item.price / 6.0).ceil
			flash[:notice] = "Sold a " + @player_character_item.item.name + " for " + @cost.to_s + " gold."
		else
			flash[:notice] = "You do not have a " + @player_character_item.item.name + " to sell."
		end
		
		#pay player
		TxWrapper.give(@pc, :gold, @cost)
		
		redirect_to :action => 'sell'
	end
	
protected
	def setup_npc_vars
		redirect_to game_feature_url() unless @pc.current_event.event.class == EventNpc
		@event = @pc.current_event.event
		@npc = @event.npc
		
		unless @npc.health.HP > 0 && @npc.health.wellness != SpecialCode.get_code('wellness','dead')
			@pc.current_event.destroy
			flash[:notice] = @npc.name + " has shuffled from this mortal coil"
			redirect_to :controller => '/game', :action => 'main'
		end
	end

	def spread_contact_disease
		Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact'))
		Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact'))
	end
end
