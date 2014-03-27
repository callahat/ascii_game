require 'test_helper'

class Game::NpcControllerTest < ActionController::TestCase
	def setup
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character][:in_kingdom] = 1
		
		@level = Level.find(:first, :conditions =>['kingdom_id = ? and level = 0', 1])
		@kl_healer = @level.level_maps.find(:first, :conditions => ['xpos = 0 and ypos = 1'])
		@kl_multi = @level.level_maps.find(:first, :conditions => ['xpos = 2 and ypos = 1'])
		
		@disease = Disease.find_by_name("airbourne disease")
	end

	def setup_sub1(kl)
		CurrentEvent.make_new(session[:player_character], kl.id)
		@next, @it = session[:player_character].current_event.next_event
		session[:player_character].current_event.update_attributes(:event_id => @it.first.id, :priority => @next)
		@direction, @completed, @message = session[:player_character].current_event.event.happens(session[:player_character])
		session[:player_character].current_event.update_attribute(:completed, @completed)
		session[:player_character].reload
		assert session[:player_character].current_event.event.class == EventNpc, session[:player_character].current_event.event.class
	end

	test "encounter healer npc" do
		setup_sub1(@kl_healer)
		get 'npc', {}, session.to_hash
		assert_response :success
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
	end
	
	test "healer npc menu options" do
		setup_sub1(@kl_healer)
		get 'smithy', {}, session.to_hash
		assert_redirected_to npc_index_url()
		
		get 'train', {}, session.to_hash
		assert_redirected_to npc_index_url()
		
		get 'buy', {}, session.to_hash
		assert_redirected_to npc_index_url()
		
		get 'sell', {}, session.to_hash
		assert_redirected_to npc_index_url()
		
		get 'heal', {}, session.to_hash
		assert_response :success
		assert @response.body =~ /Nothing more can be done/
	end
	
	test "healer npc do heal" do
		setup_sub1(@kl_healer)
		Illness.infect(session[:player_character], @disease)
		
		session[:player_character].health.update_attribute(:HP, 28)
		session[:player_character].health.update_attribute(:MP, 23)
		session[:player_character].update_attribute(:gold, 100000)
		
		get 'do_heal', {}, session.to_hash
		assert_redirected_to npc_heal_url()
		assert flash[:notice] =~ /Do what now/
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].health.HP', +2 do
			get 'do_heal', {:HP => "true"}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.MP', +7 do
			get 'do_heal', {:MP => "true"}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].illnesses.size', -1 do
			get 'do_heal', {:did => @disease.id}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] !~ /Do what now/
		end
	end
	
	test "encounter multiclass npc" do
		setup_sub1(@kl_multi)
		get 'npc', {}, session.to_hash
		assert_response :success
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
	end
	
	test "multiclass npc menu options" do
		setup_sub1(@kl_multi)
		get 'smithy', {}, session.to_hash
		assert_response :success
		
		get 'train', {}, session.to_hash
		assert_response :success
		assert_not_nil assigns(:cost_per_pt)
		
		get 'buy', {}, session.to_hash
		assert_response :success
		
		get 'sell', {}, session.to_hash
		assert_response :success
		
		get 'heal', {}, session.to_hash
		assert_response :success
		assert @response.body =~ /Nothing more can be done/
	end
	
	test "multiclass npc do buy new" do
		setup_sub1(@kl_multi)
		session[:player_character].update_attribute(:gold, 100000)
		
		assert_difference 'session[:player_character].gold', -0 do
			assert_difference 'session[:player_character].items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
				get 'do_buy_new', {}, session.to_hash
				assert flash[:notice] =~ /cannot make that/, flash[:notice]
				assert_redirected_to npc_smithy_url()
			end
		end
		flash[:notice] = ""
		old_gold = session[:player_character].gold
		assert_difference 'session[:player_character].items.find(:first, :conditions => {:item_id => 1}).quantity', +1 do
			get 'do_buy_new', {:iid => 1}, session.to_hash
			assert flash[:notice] =~ /Bought/
			session[:player_character].items.reload
			assert_redirected_to npc_smithy_url()
		end
		assert old_gold > session[:player_character].gold
	end
	
	test "multiclass npc do heal" do
		setup_sub1(@kl_multi)
		Illness.infect(session[:player_character], @disease)
		
		session[:player_character].health.update_attribute(:HP, 28)
		session[:player_character].health.update_attribute(:MP, 23)
		session[:player_character].update_attribute(:gold, 100000)
		
		get 'do_heal', {}, session.to_hash
		assert_redirected_to npc_heal_url()
		assert flash[:notice] =~ /Do what now/
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].illnesses.size', +0 do
			get 'do_heal', {:did => @disease.id}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] =~ /cannot cure/, flash[:notice]
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.HP', +2 do
			get 'do_heal', {:HP => "true"}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.MP', +7 do
			get 'do_heal', {:MP => "true"}, session.to_hash
			assert_redirected_to npc_heal_url()
			assert flash[:notice] !~ /Do what now/
		end
	end
	
	test "multiclass npc do train" do
		setup_sub1(@kl_multi)
		max_train = session[:player_character].current_event.event.npc.npc_merchant_detail.max_skill_taught
		
		get 'do_train', {}, session.to_hash
		assert_redirected_to npc_train_url()
		
		get 'do_train', {:atrib => {:str => 0, :dex => 0, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}, session.to_hash
		assert_redirected_to npc_train_url()
		
		session[:player_character].update_attribute(:gold, 10000)
		base_str = session[:player_character].base_stat[:str]
		base_dex = session[:player_character].base_stat[:dex]
		
		post 'do_train', {:atrib => {:str => 9000, :dex => 9000, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}, session.to_hash
		assert flash[:notice] =~ // #means failure
		
		#just right
		@str = (base_str * max_train / 200.0).to_i
		@dex = (base_dex * max_train / 200.0).to_i
		
		assert_difference 'session[:player_character].base_stat[:str]', +0 do
			assert_difference 'session[:player_character].stat[:str]', +(base_str * max_train / 200.0).to_i do
				assert_difference 'session[:player_character].trn_stat[:dex]', +(base_dex * max_train / 200.0).to_i do
					assert_difference 'session[:player_character].stat[:dex]', +(base_dex * max_train / 200.0).to_i do
						post 'do_train', {:atrib => {:str => @str, :dex => @dex, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}, session.to_hash
						assert_redirected_to npc_train_url()
						assert flash[:notice] =~ /successful/
					end
				end
			end
		end
	end
	
	test "multiclass npc pc sells item" do
		setup_sub1(@kl_multi)
		@item1 = Item.find(1)
		
		get 'do_sell', {}, session.to_hash
		assert_redirected_to npc_sell_url()
		assert flash[:notice] =~ /not have one/,  flash[:notice]
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].gold', +@item1.resell_value do
			get 'do_sell', {:id => 1}, session.to_hash
			assert_redirected_to npc_sell_url()
			assert flash[:notice] =~ /Sold/
		end
	end
	
	test "multiclass npc pc buys used item" do
		setup_sub1(@kl_multi)
		session[:player_character].update_attribute(:gold, 4000)
		
		get 'do_buy', {}, session.to_hash
		assert_redirected_to npc_buy_url()
		assert flash[:notice] =~ /does not have/, flash[:notice]
		flash[:notice] = ""
		
		get 'do_buy', {:id => 4}, session.to_hash
		assert_redirected_to npc_buy_url()
		assert flash[:notice] =~ /Bought a/, flash[:notice]
		assert session[:player_character].items.find(:first, :conditions => ["item_id = 4"]).quantity == 1
	end
	
	# test "king battle" do
		# get 'fight_king', {}, session.to_hash
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}, session.to_hash
		# assert_template 'battle'
		
		# assert_response :success
		# assert_not_nil assigns(:battle)
	# end
	
	# test "pc battle" do
		# session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		# session[:current_event].update_attribute(:event_id, Event.find_by_name("Sick PC encounter").id)
		# get 'fight_pc', {}, session.to_hash
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:enemy_pc)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}, session.to_hash
		# assert_template 'battle'
		
		# assert_response :success
		# assert_not_nil assigns(:battle)
	# end
	
	# test "npc battle" do
		# session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		# session[:current_event].update_attribute(:event_id, Event.find_by_name("Healthy Npc encounter").id)
		# get 'fight_npc', {}, session.to_hash
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:npc)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}, session.to_hash
		# assert_template 'battle'
		
		# assert_response :success
		# assert_not_nil assigns(:battle)
	# end
	
	# test "different valid fight options" do
		
		# session[:player_character].c_class.update_attribute(:healing_spells, true)
		# session[:player_character].c_class.update_attribute(:attack_spells, true)
		# session[:player_character].health.update_attribute(:MP, 300)
		# session[:player_character].update_attribute(:level, 300)
		
		# session[:current_event] = Event.find_by_name("Weak Monster encounter")
		# session[:current_event].happens(session[:player_character])
		# get 'battle', {}, session.to_hash
		# assert_template 'battle'
		
		# get 'fight', {:attack => nil}, session.to_hash
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
		
		# get 'fight', {:heal => HealingSpell.find_by_name("Heal Only").id, :commit => "Heal"}, session.to_hash
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
		
		# get 'fight', {:attack => AttackSpell.find_by_name("Splash Attack Spell").id, :commit => "Attack"}, session.to_hash
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
	# end
	
	# test "regicide" do
		# get 'fight_king', {}, session.to_hash
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		# get 'regicide', {}, session.to_hash
	# end
	
	# test "run away" do
		# get 'fight_king', {}, session.to_hash
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		# get 'run_away', {}, session.to_hash
	# end
end
