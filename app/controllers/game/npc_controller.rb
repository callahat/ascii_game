class Game::NpcController < ApplicationController
	#before_filter :authenticate
	before_filter :setup_pc_vars
	before_filter :setup_npc_vars

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
		
		Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact') )
		Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact') )
		
		res, msg = @npc.manufacture(@pc, params[:iid])
		flash[:notice] = msg + ( flash[:notice] ? "<br/>" + flash[:notice] : "" )
		
		redirect_to :action => 'smithy'
	end
	
	def heal
		@npc_healer_skills = @npc.npc_merchant_detail.healer_skills 
		
		@diseases_cured = @npc_healer_skills.collect{|cure| cure.disease }.compact

		if @pc.health.base_HP > @pc.health.HP && @npc_healer_skills.first.max_HP_restore > 0
			@max_HP_heal = minimum(@npc_healer_skills.first.max_HP_restore, @pc.health.base_HP - @pc.health.HP)
			@max_HP_heal_cost = (MiscMath.point_recovery_cost(@max_HP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		end
		if @pc.health.base_MP > @pc.health.MP && @npc_healer_skills.first.max_MP_restore > 0
			@max_MP_heal = minimum(@npc_healer_skills.first.max_MP_restore, @pc.health.base_MP - @pc.health.MP)
			@max_MP_heal_cost = (MiscMath.point_recovery_cost(@max_MP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		end
	end
	
	def do_heal
		heal

		if params[:did]
			res, flash[:notice] = @npc.cure_disease(@pc, params[:did])
		elsif params[:HP]
			res, flash[:notice] = @npc.heal(@pc, :HP, @max_HP_heal)
		elsif params[:MP]
			res, flash[:notice] = @npc.heal(@pc, :MP, @max_MP_heal)
		else
			#did not recognize what the player selected
			flash[:notice] = 'Do what now?'
		end

		redirect_to :action => 'heal'
	end
 
	def train
		@max_skill = TrainerSkill.find(:first, :conditions => ['min_sales <= ?',@npc.npc_merchant_detail.trainer_sales], :order => '"min_sales DESC"').max_skill_taught
		print "\nmax skill: " + @max_skill.inspect + "\n"
		@atrib = CClassLevel.new
		
		@cost_per_pt = (@pclevel * 10 * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		@flag = false
	end
	
	def do_train
		@tax, @pretax = 0,0
		
		@max_skill = TrainerSkill.find(:first, :conditions => ['min_sales <= ?',@npc.npc_merchant_detail.trainer_sales], :order => '"min_sales DESC"').max_skill_taught
		@base_cost_per_point = @pc.level * 10
		@tax_per_point = (@base_cost_per_point * (@npc.kingdom.tax_rate / 100.0)).to_i
		@cost_per_pt = @base_cost_per_point + @tax_per_point
		@flag = false
		
		#Just using this for the attributes
		@atrib = Stat.new(params[:atrib])
		
		if !@atrib.valid?
			@flag = true
		end
		#double check the max skill taught from what was entered
		["str", "dex", "mag", "int", "con", "dfn", "dam"].each{|at|
			if (@pc.base_stat[base_atr] * ( @max_skill / 100.0)).to_i < (@atrib[at.to_sym] + @pc.trn_stat[trn_atr])
				@flag = true
				@atrib.errors.add(at," cannot gain " + @atrib[at.to_sym].to_s + " points in strength")
			end 
		}
		
		@total_base = @atrib.str + @atrib.dex + @atrib.mag + @atrib.int + @atrib.con + @atrib.dam + @atrib.dfn
		@pretax = @total_base * @base_cost_per_point
		@tax = (@pretax * @tax_per_point).to_i
		
		@total_cost = @pretax + @tax
		
		unless TxWrapper.take(@pc, :gold, @total_cost)
			@flag = true
			flash[:notice] = "Not enough gold to train that much\n"
		else
			Kingdom.pay_tax(@tax, @npc.kingdom_id) unless @tax == 0
			pay_npc(@npc, @pretax, :trainer_sales) unless @pretax == 0
		end
		
		#only save chanegs if no flag thrown
		if !@flag
			@trn = @pc.trn_stat
			@stat = @pc.stat
			@gain = Stat.new(@atrib)
			StatPcTrn.transaction do
				@trn.lock!
				@trn.add_stats(@atrib)
				@trn.save!
			end
			StatPc.transaction do
				@stat.lock!
				@stat.add_stats(@atrib)
				@stat.save!
			end
			flash[:notice] = "Training sucessful."
		else
			print "Invalid numbers"
		end
		redirect_to :action => 'train'
	end
	
	def buy
		@stocks = NpcStock.get_page(params[:page], @npc.id)
	end
	
	def do_buy
		@stock = @npc.npc_stocks.find(:first, :conditions => ['id = ?', params[:id]])
		@tax,@pretax = 0,0
		
		if @stock && !NpcStock.update_inventory(@npc.id, @stock.item_id, -1)
			@pretax = @stock.item.price / 2
			@tax = (@pretax * (@npc.kingdom.tax_rate / 100.0)).to_i
			@cost = @tax + @pretax
			
			if !TxWrapper.take(@pc, :gold, @cost)
				flash[:notice] = "Its out of your price range"
				NpcStock.update_inventory(@npc.id, @stock.item_id, 1)
			elsif PlayerCharacterItem.update_inventory(@pc.id,@stock.item_id,1)
				flash[:notice] = "Bought a " + @stock.item.name + " for " + @cost.to_s + " gold."
			end
		
			Kingdom.pay_tax(@tax, @npc.kingdom_id)
			#gief monies plox
			pay_npc(@npc, @pretax, nil)

			Illness.spread(@player_character, @npc, SpecialCode.get_code('trans_method','contact') )
			Illness.spread(@npc, @player_character, SpecialCode.get_code('trans_method','contact') )
		else
			flash[:notice] = @npc.name + " does not have a " + @stock.item.name + " for sale."
		end
		
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
			Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact'))
			Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact'))
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

	
	def pay_npc(npc, amount, sale_type)
		TxWrapper.give(npc, :gold, amount)
		TxWrapper.give(npc.npc_merchant_detail, :sale_type, amount) if sale_type
	end
end
