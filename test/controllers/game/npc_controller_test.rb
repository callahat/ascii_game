require 'test_helper'

class Game::NpcControllerTest < ActionController::TestCase
	def setup
		sign_in Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")

		@level = kingdoms(:kingdom_one).levels.where(level: 0).first
		@kl_healer = @level.level_maps.where(xpos: 0, ypos: 1).first
		@kl_multi = @level.level_maps.where(xpos: 2, ypos: 1).first
		
		@disease = Disease.find_by_name("airbourne disease")
	end

	def setup_sub1(kl)
		CurrentEvent.make_new(session[:player_character], kl.id)
		@next, @it = session[:player_character].current_event.next_event
		session[:player_character].current_event.update_attributes(:event_id => @it.first.id, :priority => @next)
		@direction, @completed, @message = session[:player_character].current_event.event.happens(session[:player_character])
		session[:player_character].current_event.update_attribute(:completed, @completed)
		session[:player_character].reload
		assert_equal EventNpc, session[:player_character].current_event.event.class
	end

	test "encounter healer npc" do
		setup_sub1(@kl_healer)
		get 'npc', {}
		assert_response :success
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
	end
	
	test "healer npc menu options" do
		setup_sub1(@kl_healer)
		get 'smithy', {}
		assert_redirected_to npc_game_npc_path
		
		get 'train', {}
		assert_redirected_to npc_game_npc_path
		
		get 'buy', {}
		assert_redirected_to npc_game_npc_path
		
		get 'sell', {}
		assert_redirected_to npc_game_npc_path
		
		get 'heal', {}
		assert_response :success
		assert @response.body =~ /Nothing more can be done/
	end
	
	test "healer npc do heal" do
		setup_sub1(@kl_healer)
		Illness.infect(session[:player_character], @disease)
		
		session[:player_character].health.update_attribute(:HP, 28)
		session[:player_character].health.update_attribute(:MP, 23)
		session[:player_character].update_attribute(:gold, 100000)
		
		get 'do_heal', {}
		assert_redirected_to heal_game_npc_path
		assert flash[:notice] =~ /Do what now/
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].health.HP', +2 do
			get 'do_heal', {:HP => "true"}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.MP', +7 do
			get 'do_heal', {:MP => "true"}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].illnesses.size', -1 do
			get 'do_heal', {:did => @disease.id}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] !~ /Do what now/
		end
	end
	
	test "encounter multiclass npc" do
		setup_sub1(@kl_multi)
		get 'npc', {}
		assert_response :success
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
	end
	
	test "multiclass npc menu options" do
		setup_sub1(@kl_multi)
		get 'smithy', {}
		assert_response :success
		
		get 'train', {}
		assert_response :success
		assert_not_nil assigns(:cost_per_pt)
		
		get 'buy', {}
		assert_response :success
		
		get 'sell', {}
		assert_response :success
		
		get 'heal', {}
		assert_response :success
		assert @response.body =~ /Nothing more can be done/
	end
	
	test "multiclass npc do buy new" do
		setup_sub1(@kl_multi)
		session[:player_character].update_attribute(:gold, 100000)
		
		assert_difference 'session[:player_character].gold', -0 do
			assert_difference "session[:player_character].items.where(item_id: #{items(:item_1).id}).first.quantity", +0 do
				get 'do_buy_new', {}
				assert flash[:notice] =~ /cannot make that/, flash[:notice]
				assert_redirected_to smithy_game_npc_path
			end
		end
		flash[:notice] = ""
		old_gold = session[:player_character].gold
		assert_difference "session[:player_character].items.where(item_id: #{items(:item_1).id}).first.quantity", +1 do
			get 'do_buy_new', {:iid => items(:item_1).id}
			assert flash[:notice] =~ /Bought/
			session[:player_character].items.reload
			assert_redirected_to smithy_game_npc_path
		end
		assert old_gold > session[:player_character].gold
	end
	
	test "multiclass npc do heal" do
		setup_sub1(@kl_multi)
		Illness.infect(session[:player_character], @disease)
		
		session[:player_character].health.update_attribute(:HP, 28)
		session[:player_character].health.update_attribute(:MP, 23)
		session[:player_character].update_attribute(:gold, 100000)
		
		get 'do_heal', {}
		assert_redirected_to heal_game_npc_path
		assert flash[:notice] =~ /Do what now/
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].illnesses.size', +0 do
			get 'do_heal', {:did => @disease.id}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] =~ /cannot cure/, flash[:notice]
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.HP', +2 do
			get 'do_heal', {:HP => "true"}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] !~ /Do what now/
		end
		flash[:notice] = ""
		assert_difference 'session[:player_character].health.MP', +7 do
			get 'do_heal', {:MP => "true"}
			assert_redirected_to heal_game_npc_path
			assert flash[:notice] !~ /Do what now/
		end
	end
	
	test "multiclass npc do train" do
		setup_sub1(@kl_multi)
		max_train = session[:player_character].current_event.event.npc.npc_merchant_detail.max_skill_taught
		
		get 'do_train', {}
		assert_redirected_to train_game_npc_path
		
		get 'do_train', {:atrib => {:str => 0, :dex => 0, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}
		assert_redirected_to train_game_npc_path
		
		session[:player_character].update_attribute(:gold, 10000)
		base_str = session[:player_character].base_stat[:str]
		base_dex = session[:player_character].base_stat[:dex]
		
		post 'do_train', {:atrib => {:str => 9000, :dex => 9000, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}
		assert flash[:notice] =~ // #means failure
		
		#just right
		@str = (base_str * max_train / 200.0).to_i
		@dex = (base_dex * max_train / 200.0).to_i
		
		assert_difference 'session[:player_character].base_stat[:str]', +0 do
			assert_difference 'session[:player_character].stat[:str]', +(base_str * max_train / 200.0).to_i do
				assert_difference 'session[:player_character].trn_stat[:dex]', +(base_dex * max_train / 200.0).to_i do
					assert_difference 'session[:player_character].stat[:dex]', +(base_dex * max_train / 200.0).to_i do
						post 'do_train', {:atrib => {:str => @str, :dex => @dex, :dam => 0, :dfn => 0, :con => 0, :mag => 0, :int => 0}}
						assert_redirected_to train_game_npc_path
						assert flash[:notice] =~ /successful/
					end
				end
			end
		end
	end
	
	test "multiclass npc pc sells item" do
		setup_sub1(@kl_multi)
		@item1 = items(:item_1)
		
		get 'do_sell', {}
		assert_redirected_to sell_game_npc_path
		assert flash[:notice] =~ /not have one/,  flash[:notice]
		flash[:notice] = ""
		
		assert_difference 'session[:player_character].gold', +@item1.resell_value do
			get 'do_sell', {id: @item1.id}
			assert_redirected_to sell_game_npc_path
			assert flash[:notice] =~ /Sold/
		end
	end
	
	test "multiclass npc pc buys used item" do
		item_id = items(:item_4).id

		setup_sub1(@kl_multi)
		session[:player_character].update_attribute(:gold, 4000)
		
		get 'do_buy', {}
		assert_redirected_to buy_game_npc_path
		assert flash[:notice] =~ /does not have/, flash[:notice]
		flash[:notice] = ""
		
		get 'do_buy', {id: item_id}
		assert_redirected_to buy_game_npc_path
		assert flash[:notice] =~ /Bought a/, flash[:notice]
		assert session[:player_character].items.where(item_id: item_id).first.quantity == 1
	end
	
	# test "king battle" do
		# get 'fight_king', {}
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}
		# assert_template 'battle'
		
		# assert_response :success
		# assert_not_nil assigns(:battle)
	# end
	
	# test "pc battle" do
		# session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		# session[:current_event].update_attribute(:event_id, Event.find_by_name("Sick PC encounter").id)
		# get 'fight_pc', {}
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:enemy_pc)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}
		# assert_template 'battle'
		
		# assert_response :success
		# assert_not_nil assigns(:battle)
	# end
	
	# test "npc battle" do
		# session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		# session[:current_event].update_attribute(:event_id, Event.find_by_name("Healthy Npc encounter").id)
		# get 'fight_npc', {}
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:npc)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		
		# get 'battle', {}
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
		# get 'battle', {}
		# assert_template 'battle'
		
		# get 'fight', {:attack => nil}
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
		
		# get 'fight', {:heal => HealingSpell.find_by_name("Heal Only").id, :commit => "Heal"}
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
		
		# get 'fight', {:attack => AttackSpell.find_by_name("Splash Attack Spell").id, :commit => "Attack"}
		# assert_not_nil flash[:battle_report]
		# assert_redirected_to :action => 'battle'
	# end
	
	# test "regicide" do
		# get 'fight_king', {}
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		# get 'regicide', {}
	# end
	
	# test "run away" do
		# get 'fight_king', {}
		# assert_not_nil assigns(:pc)
		# assert_not_nil assigns(:kingdom)
		# assert_response :redirect
		# assert_redirected_to :action => 'battle'
		# get 'run_away', {}
	# end
end
