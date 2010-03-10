class Game::NpcController < ApplicationController
	before_filter :authenticate

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_buy, :do_train, :do_buy_new, :do_sell ], :redirect_to => { :action => :npc }
	
	def npc
		@npc = session[:current_event].event_npc.npc
		
		Illness.spread(session[:player_character], @npc, SpecialCode.get_code('trans_method','air'))
		Illness.spread(@npc, session[:player_character], SpecialCode.get_code('trans_method','air'))
		
		if @npc.health.HP > 0 && @npc.health.wellness != SpecialCode.get_code('wellness','dead')
			session[:completed] = true
		else
			flash[:notice] = @npc.name + " has shuffled from this mortal coil"
			render :action => '../complete'
		end
	end
	
	def smithy
		session[:player_character] = PlayerCharacter.find(session[:player_character][:id])
		@npc = session[:current_event].event_npc.npc
		@can_make = @npc.npc_blacksmith_items
	end
	
	def do_buy_new
		@npc = session[:current_event].event_npc.npc
		@can_make = @npc.npc_blacksmith_items
		@item = Item.find(params[:iid])
		@tax = (@item.price * (@npc.kingdom.tax_rate / 100.0)).to_i
		@cost = @item.price + @tax
		
		if @can_make.exists?(:item_id => params[:iid])
		@enough_money = false
		PlayerCharacter.transaction do
			session[:player_character].lock!
				enough_money = session[:player_character].gold >= @cost
			if @enough_money
					session[:player_character].gold -= @cost
					flash[:notice] = "Bought a " + @item.name + " for " + @cost.to_s + " gold."
				end
			
				session[:player_character].save!
			end
			if @enough_money
				PlayerCharacterItem.update_inventory(session[:player_character].id,@item.id,1)
				Kingdom.pay_tax(@tax, @npc.kingdom_id)
				pay_npc(@npc, @item.price, :blacksmith_sales)
			end
			
			Illness.spread(@player_character, @npc, SpecialCode.get_code('trans_method','contact') )
			Illness.spread(@npc, @player_character, SpecialCode.get_code('trans_method','contact') )
		else
			flash[:notice] = @npc.name + " cannot make " + @item.name
		end
		
		redirect_to :action => 'smithy'
	end
	
	
	def heal
		#update session
		session[:player_character] = PlayerCharacter.find(session[:player_character][:id])
		@npc = session[:current_event].event_npc.npc
		@diseases_cured = []
		@npc_healer_skills = HealerSkill.find(:all, :conditions => ['min_sales <= ?',@npc.npc_merchant.healing_sales], :order => '"min_sales DESC"')
		
		#create the diseases cured array
		for cure in @npc_healer_skills
			if cure.disease_id
				@diseases_cured << cure
			end
		end
		print "\n" + session[:player_character].health.HP.to_s
		if session[:player_character].health.base_HP > session[:player_character].health.HP && @npc_healer_skills.first.max_HP_restore > 0
			printf "\nHP"
			@max_HP_heal = minimum(@npc_healer_skills.first.max_HP_restore, session[:player_character].health.base_HP - session[:player_character].health.HP)
			@max_HP_heal_cost = (calc_point_recovery_cost(@max_HP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		end
		if session[:player_character].health.base_MP > session[:player_character].health.MP && @npc_healer_skills.first.max_MP_restore > 0
		printf "\nMP"
			@max_MP_heal = minimum(@npc_healer_skills.first.max_MP_restore, session[:player_character].health.base_MP - session[:player_character].health.MP)
			@max_MP_heal_cost = (calc_point_recovery_cost(@max_MP_heal) * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		end
	end
	
	def do_heal
		@npc = session[:current_event].event_npc.npc
		@tax, @pretax = 0,0
	
		PlayerCharacter.transaction do
			session[:player_character].lock!
		
			if params[:did]
				@disease = Disease.find(params[:did])
				@pretax = Disease.abs_cost(@disease)
				@tax = (@pretax * (@npc.kingdom.tax_rate / 100.0)).to_i
				@cost = @pretax + @tax
			
				if session[:player_character].gold >= @cost
					session[:player_character].illnesses.find(:first, :conditions => ['disease_id = ?', @disease.id]).destroy
				
					@stat = session[:player_character].dup
					@stat.add_stats(@disease.stat)
					@stat.save

					session[:player_character].gold -= @cost
					session[:player_character].save! #dont need the lock anymore, free it up
			
					flash[:notice] = 'Cured ' + @disease.name
				else
					session[:player_character].save!
					flash[:notice] = 'Not enough gold to cure ' + @disease.name
				end
			elsif params[:HP]
				@npc = session[:current_event].event_npc.npc
				@npc_healer_skills = HealerSkill.find(:all, :conditions => ['min_sales <= ?',@npc.npc_merchant.healing_sales], :order => '"min_sales DESC"')
				@max_HP_heal = minimum(@npc_healer_skills.first.max_HP_restore,session[:player_character].health.base_HP - session[:player_character].health.HP)
				@pretax = calc_point_recovery_cost(@max_HP_heal)
				@tax = (@pretax * (@npc.kingdom.tax_rate / 100.0)).to_i
				@max_HP_heal_cost = @pretax + @tax
			
				if session[:player_character].gold >= @max_HP_heal_cost
					session[:player_character].health.HP += @max_HP_heal
					session[:player_character].gold -= @max_HP_heal_cost
								
					flash[:notice] = 'Restored HP'
				else
					flash[:notice] = 'Not enough gold to restore HP'
				end
			elsif params[:MP]
				@npc = session[:current_event].event_npc.npc
				@npc_healer_skills = HealerSkill.find(:all, :conditions => ['min_sales <= ?',@npc.npc_merchant.healing_sales], :order => '"min_sales DESC"')
				@max_MP_heal = minimum(@npc_healer_skills.first.max_MP_restore,@player_character.max_MP - @player_character.MP)
				@pretax = calc_point_recovery_cost(@max_MP_heal)
				@tax = (@pretax * (@npc.kingdom.tax_rate / 100.0)).to_i
				@max_MP_heal_cost = @pretax + @tax
			
				if @player_character.gold >= @max_MP_heal_cost
					@player_character.MP += @max_MP_heal
					@player_character.gold -= @max_MP_heal_cost
				
					flash[:notice] = 'Restored MP'
				else
					flash[:notice] = 'Not enough gold to restore MP'
				end
			else
				#did not recognize what the player selected
				flash[:notice] = 'Do what now?'
			end
			session[:player_character].save!
		end
		Kingdom.pay_tax(@tax, @npc.kingdom_id) unless @tax == 0
		pay_npc(@npc, @pretax, :healing_sales) unless @pretax == 0

		redirect_to :action => 'heal'
	end
 
	def train
		#refresh the session cache for the player
		session[:player_character] = PlayerCharacter.find(session[:player_character][:id])
		
		@npc = session[:current_event].event_npc.npc
		@max_skill = TrainerSkill.find(:first, :conditions => ['min_sales <= ?',@npc.npc_merchant.trainer_sales], :order => '"min_sales DESC"').max_skill_taught
		print "\nmax skill: " + @max_skill.inspect + "\n"
		@atrib = CClassLevel.new
		
		@cost_per_pt = (session[:player_character][:level] * 10 * (1 + @npc.kingdom.tax_rate / 100.0)).to_i
		@flag = false
	end
	
	def do_train
		@npc = session[:current_event].event_npc.npc
		@tax, @pretax = 0,0
		PlayerCharacter.transaction do
			session[:player_character].lock!
		
			@max_skill = TrainerSkill.find(:first, :conditions => ['min_sales <= ?',@npc.npc_merchant.trainer_sales], :order => '"min_sales DESC"').max_skill_taught
			@base_cost_per_point = session[:player_character][:level] * 10
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
			base_atr = ("base_"+at).to_sym
			trn_atr = ("trn_"+at).to_sym
				if (@player_character[base_atr] * ( @max_skill / 100.0)).to_i < (@atrib[at.to_sym] + @player_character[trn_atr])
					@flag = true
					@atrib.errors.add(at," cannot gain " + @atrib[at.to_sym].to_s + " points in strength")
				end 
			}
		
			@total_base = @atrib.str + @atrib.dex + @atrib.mag + @atrib.int + @atrib.con + @atrib.dam + @atrib.dfn
			@pretax = @total_base * @base_cost_per_point
			@tax = (@pretax * @tax_per_point).to_i
		
			@total_cost = @pretax + @tax
		
			if @total_cost > @player_character.gold
				@flag = true
				flash[:notice] = "Not enough gold to train that much\n"
			end
		
			#only save chanegs if no flag thrown
			if !@flag
				@trn = @player_character.trn_stat
				@stat = @player_character.stat
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
			
				@player_character.gold -= @total_cost
			
			flash[:notice] = "Training sucessful."
			else
				print "Invalid numbers"
				#release teh lock
				#render :action => 'train'
				#return
			end
		
			session[:player_character].save!
		end
		Kingdom.pay_tax(@tax, @npc.kingdom_id) unless @tax == 0
		pay_npc(@npc, @pretax, :trainer_sales) unless @pretax == 0
	
		redirect_to :action => 'train'
	end
	
	def buy
		@npc = session[:current_event].event_npc.npc
		@stocks = NpcStock.get_page(params[:page], @npc.id)
	end
	
	def do_buy
		@npc = session[:current_event].event_npc.npc
		@stock = @npc.npc_stocks.find(:first, :conditions => ['id = ?', params[:id]])
		@tax,@pretax = 0,0
		NpcStock.transaction do
			@stock.lock! if @stock
			if @stock && @stock.quantity > 0
				@pretax = @stock.item.price / 2
				@tax = (@pretax * (@npc.kingdom.tax_rate / 100.0)).to_i
				@cost = @tax + @pretax
		
				#PC TRANSACTION
				session[:player_character].lock!
				if PlayerCharacterItem.update_inventory(session[:player_character].id,@stock.item_id,1)
					session[:player_character].gold -= @cost
					@stock.quantity -= 1
					flash[:notice] = "Bought a " + @stock.item.name + " for " + @cost.to_s + " gold."
				end
				session[:player_character].save!
				#/PC TRANSACTION
				@stock.save!
		
				Kingdom.pay_tax(@tax, @npc.kingdom_id)
				#gief monies plox
				pay_npc(@npc, @pretax, nil)
		
				Illness.spread(@player_character, @npc, SpecialCode.get_code('trans_method','contact') )
				Illness.spread(@npc, @player_character, SpecialCode.get_code('trans_method','contact') )
			else
				flash[:notice] = @npc.name + " does not have a " + @stock.item.name + " for sale."
			end
		end
		
		redirect_to :action => 'buy'
	end
	
	def sell
		@pc = PlayerCharacter.find(session[:player_character][:id])
		@npc = session[:current_event].event_npc.npc
		@player_character_items = PlayerCharacterItem.get_page(params[:page], @pc.id)
	end
	
	def do_sell
		@pc = session[:player_character]
		@npc = session[:current_event].event_npc.npc
		@player_character_item = @pc.items.find(:first, :conditions => ['id = ?', params[:id]])
		PlayerCharacterItem.transaction do
		@player_character_item.lock! if @player_character_item
	
			if @player_character_item && @player_character_item.quantity > 0
				NpcStock.update_inventory(@npc.id,@player_character_item.item_id,1)
				@cost = (@player_character_item.item.price / 6.0).ceil
				@player_character_item.quantity -= 1
				flash[:notice] = "Sold a " + @player_character_item.item.name + " for " + @cost.to_s + " gold."
				Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method','contact'))
				Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method','contact'))
			else
				flash[:notice] = "You do not have a " + @player_character_item.item.name + " to sell."
			end
			@player_character_item.save!
		end
	
		#pay player
		PlayerCharacter.transaction do
			@pc.lock!
			@pc.gold += @cost	
			@pcc.save!
		end
		
		redirect_to :action => 'sell'
	end
	
protected
	def calc_point_recovery_cost(amount)
		print "balls " + amount.to_s + "\n"
		print "tits " + Math.log(amount * 10 + 1).to_s +	"/" + Math.log(amount + 1.1).to_s
		return (Math.log(amount * 10 + 1) / Math.log(amount + 1.1) ).ceil * 10
	end
	
	def pay_npc(npc, amount, sale_type)
		Npc.transaction do
			npc.lock!
			npc.gold += amount
			npc.save!
		end
		if sale_type
			NpcMerchant.transaction do
			npc.npc_merchant.lock!
			npc.npc_merhant[sale_type] += amount
			npc.npc_merchant.save!
			end
		end
	end
end
