Rails.application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  get       'login'             =>  'account#login'
  get       'logout'            =>  'account#logout'
  get       'register'          =>  'account#new'
  get       'character'         =>  'character#menu'
  get       'choose_character'  =>  'character#choose_character'

  get       'characterse'       =>  'characterse#menu'

  get       'game_feature'      =>  'game#feature'
  get       'game_main'         =>  'game#main'
  get       'complete'          =>  'game#complete'

  #Game::* controllers
  get       'game/battle'           =>  'game/battle', :action => :battle
  get       'game/battle/:action'   =>  'game/battle'
  get       'game/court/:action'    =>  'game/court'

  get       'game/do_heal'        =>  'game#do_heal',    :via => :post
  get       'game/do_choose'      =>  'game#do_choose',  :via => :post
  get       'game/do_train'       =>  'game#do_train',   :via => :post
  get       'game/do_spawn'       =>  'game#do_spawn',   :via => :post

  get       'game/do_heal'        =>  'game#feature',    :via => :get
  get       'game/do_choose'      =>  'game#feature',    :via => :get
  get       'game/do_train'       =>  'game#feature',    :via => :get
  get       'game/do_spawn'       =>  'game#feature',    :via => :get

  get       'game/leave_kingdom'  =>  'game#leave_kingdom'
  get       'game/spawn_kingdom'  =>  'game#spawn_kingdom'
  get       'game/make_camp'      =>  'game#make_camp'
  get       'game/world_move/:id' =>  'game#world_move'

  #Game::QuestController
  get       'quest_index'       =>  'game/quests#index'
  get       'do_decline'        =>  'game/quests#do_decline'
  get       'do_join_quest'     =>  'game/quests#do_join'
  get       'do_complete_quest' =>  'game/quests#do_complete'
  get       'do_reward_quest'   =>  'game/quests#do_reward'

  #Game::NpcController
  get       'npc_index'         =>  'game/npc#npc'
  get       'npc_smithy'        =>  'game/npc#smithy'
  get       'npc_do_buy_new'    =>  'game/npc#do_buy_new'
  get       'npc_heal'          =>  'game/npc#heal'
  get       'npc_do_heal'       =>  'game/npc#do_heal'
  get       'npc_train'         =>  'game/npc#train'
  get       'npc_do_train'      =>  'game/npc#do_train'
  get       'npc_buy'           =>  'game/npc#buy'
  get       'npc_do_buy'        =>  'game/npc#do_buy'
  get       'npc_sell'          =>  'game/npc#sell'
  get       'npc_do_sell'       =>  'game/npc#do_sell'

  get       'management'        =>  'management#main_index'

  #ManagementController
  get       'mgmt_levels'       =>  'management/levels#index'
  get       'mgmt_levels_show'  =>  'management/levels#show'
  get       'mgmt_levels_new'   =>  'management/levels#new'
  post      'mgmt_levels_create'=>  'management/levels#create'
  get       'mgmt_levels_edit'  =>  'management/levels#edit'
  post      'mgmt_levels_update'=>  'management/levels#update'

  #PrefListController
  get       'management/pref_list'                =>  'management/pref_list#index'
  post      'management/pref_list/drop_from_list' =>  'management/pref_list#drop_from_list'
  post      'management/pref_list/add_to_list'    =>  'management/pref_list#add_to_list'
  # TODO: probably don't need these routes
  get       'management/pref_list/drop_from_list' =>  'management/pref_list#index', as: 'management_pref_list_from_drop_from_list'
  get       'management/pref_list/add_to_list'    =>  'management/pref_list#index', as: 'management_pref_list_from_add_to_list'

  # TODO: is this needed?
  get       'management/main_index'  => 'management#main_index', :as => "management_main_index"

  get       'management/events/new' => 'management/events#new'

  namespace :management do
    resources :castles do
      collection do
        get 'throne'
        get 'throne_level'
        post 'throne_square'
        post 'set_throne'
      end
    end
    resources :creatures, :features do
      get 'pref_lists', :on => :collection
    end
    resources :events do
      get 'pref_lists', :on => :collection
    end
    resources :images
    resources :kingdom_bans
    resources :kingdom_entries do
      collection do
        get 'show'
        get 'index'
        get 'edit'
        post 'update'
      end
    end
    resources :kingdom_finances do
      collection do
        get 'show'
        get 'index'
        get 'edit'
        post 'withdraw'
        post 'deposit'
        post 'adjust_tax'
      end
    end
    resources :kingdom_items
    resources :kingdom_notices
    resources :kingdom_npcs, :except => [:show] do
      collection do
        get :list
        get ':action/:id', :only => [ :edit, :assign_store ]
        post ':action/:id', :only => [ :hire_merchant, :hire_guard, :turn_away ]
      end
    end
    resources :kingdom_npcs, :only => [:show]
    resources :levels
    resources :quests
  end

  namespace :admin do
    resource :attack_spells
    resource :base_items
    resource :blacksmith_skills
    resource :c_classes
    resource :creatures
    resource :diseases
    resource :healer_skills
    resource :healing_spells
    resource :items
    resource :maintenance
    resource :name_surfixes
    resource :name_titles
    resource :names
    resource :npcs
    resource :races
    resource :trainer_skills
    resource :world_maps
    resource :worlds
  end

  #ForumsController
  get       'forums'                                        =>  'forum#boards',     :as => "forums"
  get       'forums/:bname'                                 =>  'forum#threds',     :as => "boards"
  get       'forums/:bname/:tname'                          =>  'forum#view_thred', :as => "threds"

  get       'forum_action/:bname/:tname/:forum_node_id/:action' =>  'forum',            :as => "thred_action"
  get       'forum_action/:bname/:forum_node_id/:action'        =>  'forum',            :as => "board_action"
  get       'forum_action/:forum_node_id/:action'               =>  'forum',            :as => "forum_action"



  #resource  :forum

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

  # TODO: Take this away
  get     ':controller(/:action(/:id(.:format)))'
end
