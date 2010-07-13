ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.root :controller => 'home', :action => 'index'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'
	map.login				'login',			:controller => 'account', :action => 'login'
	map.logout			'logout',			:controller => 'account', :action => 'logout'
	map.register		'register',		:controller => 'account', :action => 'new'
	map.character		'character',	:controller => 'character', :action => 'menu'
	map.choose_character	'choose_character',		:controller => 'character', :action => 'choose_character'
	
	
	map.game_feature		'game',				:controller => 'game', :action => 'feature'
	map.game_main				'game/main',				:controller => 'game', :action => 'main'
	map.complete				'game/complete',		:controller => 'game', :action => 'complete'
	
	#QuestController
	map.quest_index					'game/quests',							:controller => 'game/quests', :action => 'index'
	map.do_decline					'game/quests/do_decline',		:controller => 'game/quests', :action => 'do_decline'
	map.do_join_quest				'game/quests/do_join',			:controller => 'game/quests', :action => 'do_join'
	map.do_complete_quest		'game/quests/do_complete',	:controller => 'game/quests', :action => 'do_complete'
	map.do_reward_quest			'game/quests/do_reward',		:controller => 'game/quests', :action => 'do_reward'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
