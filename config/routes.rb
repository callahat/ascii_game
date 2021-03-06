Rails.application.routes.draw do
  devise_for :players, controllers: { registrations: "registrations" }
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resource  :account, controller: :account, only: [:show] do
    # not sure if still need what action
    get :what
  end

  resource :character, controller: :character, only: [] do
    collection do
      get  'new'
      get  'namenew'
      post 'namenew'
      post 'create', action: :create, as: :create
      post 'do_chose/:id', action: :do_choose, as: :do_choose
      get  'menu'
      post 'do_retire/:id', action: :do_retire, as: :do_retire
      post 'do_unretire/:id', action: :do_unretire, as: :do_unretire
      post 'do_destroy/:id', action: :do_destroy, as: :do_destroy
      get  'do_image_update/:id', action: :do_image_update, as: :do_image_update
      post 'updateimage/:id', action: :updateimage
      get  'raise_level', action: :raise_level
      post 'gainlevel'
    end
  end

  resource :characterse, controller: :characterse, only: [:show] do
    collection do
      get  'attack_spells'
      get  'healing_spells'
      get  'infections'
      get  'pc_kills'
      get  'npc_kills'
      get  'genocides'
      get  'done_quests'
      get  'inventory'
      post 'equip/:id', action: :equip
      post 'do_equip/:id', action: :do_equip
      post 'unequip/:id', action: :unequip
    end
  end

  resource :game, only: [], controller: :game do
    get  :main
    get  :leave_kingdom
    get  'world_move/:id', action: :world_move, as: :world_move
    get  :feature
    post :do_choose
    get  :wave_at_pc
    get  :make_camp
    get  :complete
    get  :spawn_kingdom
    post :do_spawn
  end

  namespace :game do
    resource :battle, controller: :battle, only: [] do
      post :fight_pc
      post :fight_npc
      post :fight_king
      get  :battle
      post :fight
      post :run_away
      get  :regicide
      post :fate_of_throne
    end
    resource :court, controller: :court, only: [] do
      get  :throne
      post :join_king
      post :king_me
      get  :castle
      get  :bulletin
    end
    resource :quests, only: [:show] do
      post :do_decline
      post :do_join
      get  :do_complete
      get  :do_reward
    end
    resource :npc, controller: :npc, only: [] do
      get  :npc
      get  :smithy
      get  :do_buy_new
      get  :heal
      post :do_heal
      get  :train
      post :do_train
      get  :buy
      post :do_buy
      get  :sell
      post :do_sell
    end
  end

  namespace :management do
    root action: :main_index
    get  :helptext
    get  :choose_kingdom
    post :select_kingdom
    get  :retire
    post :retire
    post :do_retire

    resource :castles do
      collection do
        get 'levels'
        get 'throne'
        get 'throne_level'
        post 'throne_square'
        post 'set_throne'
      end
    end
    resources :creatures do
      get 'pref_lists', :on => :collection
      post :arm, on: :member
    end
    resources :events do
      get 'pref_lists', :on => :collection
      post :new, on: :member
      post :arm, on: :member
    end
    resources :features do
      get 'pref_lists', :on => :collection
      post   :arm, on: :member
      collection do
      get    :new_feature_event
      post   :create_feature_event
      get    :edit_feature_event
      patch  :update_feature_event
      delete :destroy_feature_event
      end
    end
    resources :images
    resources :kingdom_bans, except: [:edit, :update]
    resource  :kingdom_entries, only: [:show, :edit, :update]
    resource  :kingdom_finances, only: [:show, :edit] do
      collection do
        post 'withdraw'
        post 'deposit'
        post 'adjust_tax'
      end
    end
    resources :kingdom_items, only: [:index] do
      collection do
        get  :list_inventory
        get  :store
        post :do_store
        get  :remove
        post :do_take
      end
    end
    resources :kingdom_notices, except: [:show]
    resources :kingdom_npcs, only: [:index, :show] do
      member do
        get  :edit
        get  :assign_store
        post :hire_merchant
        post :hire_guard
        post :turn_away
      end
    end
    resources :levels, except: [:destroy]
    get       'pref_list'                =>  'pref_list#index'
    post      'pref_list/drop_from_list' =>  'pref_list#drop_from_list'
    post      'pref_list/add_to_list'    =>  'pref_list#add_to_list'
    resources :quests do
      member do
        post :activate
        post :retire
      end
      resources :quest_reqs, as: :reqs, only: [:new, :create, :edit, :update, :destroy] do
        collection do
          get :type
        end
      end
    end
  end

  namespace :admin do
    root controller: :attack_spells, action: :index

    resources :attack_spells
    resources :base_items
    resources :blacksmith_skills
    resources :c_classes
    resources :creatures do
      post :arm, on: :member
    end
    resources :diseases
    resources :healer_skills
    resources :healing_spells
    resources :items
    resources :name_surfixes, except: [:show]
    resources :name_titles, except: [:show]
    resources :names, except: [:show]
    resources :npcs
    resources :players, except: [:destroy]
    resources :races
    resources :trainer_skills, except: [:show]

    resources :worlds, except: [:destroy] do
      resources :world_maps, except: [:destroy], as: :maps
    end
  end

  #ForumsController
  get       'forums/new_board'                              => 'forum#new_board'
  get       'forums/:bname/new_thred'                       => 'forum#new_thred'
  post      'forums/:bname/create_thred'                    => 'forum#create_thred'
  post      'forums/create_board'                           => 'forum#create_board'

  get       'forums'                                        =>  'forum#boards',     :as => "forums"
  get       'forums/:bname'                                 =>  'forum#threds',     :as => "boards"
  get       'forums/:bname/:tname'                          =>  'forum#view_thred', :as => "threds"
  get       'forums/:bname/:tname/:action', controller: 'forum'
  post      'forums/:bname/:tname/:action', controller: 'forum'

  get       'forum_action/:bname/:tname/:forum_node_id/:action' =>  'forum',            :as => "thred_action"
  post      'forum_action/:bname/:tname/:forum_node_id/:action' =>  'forum'
  get       'forum_action/:bname/:forum_node_id/:action'        =>  'forum',            :as => "board_action"
  post      'forum_action/:bname/:forum_node_id/:action'        =>  'forum'
  get       'forum_action/:forum_node_id/:action'               =>  'forum',            :as => "forum_action"
  post      'forum_action/:forum_node_id/:action'               =>  'forum'

  post      'forums/do_promote/:player_id'  => 'forums#do_promote'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

  # get     ':controller(/:action(/:id(.:format)))'
end
