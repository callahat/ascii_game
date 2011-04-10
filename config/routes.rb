AsciiGame3::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  match     'login'             =>  'account#login'
  match     'logout'            =>  'account#logout'
  match     'register'          =>  'account#new'
  match     'character'         =>  'character#menu'
  match     'choose_character'  =>  'character#choose_character'

  match     'game_feature'      =>  'game#feature'
  match     'game_main'         =>  'game#main'
  match     'complete'          =>  'game#complete'
    
  #QuestController
  match     'quest_index'       =>  'game/quests#index'
  match     'do_decline'        =>  'game/quests#do_decline'
  match     'do_join_quest'     =>  'game/quests#do_join'
  match     'do_complete_quest' =>  'game/quests#do_complete'
  match     'do_reward_quest'   =>  'game/quests#do_reward'

  #NpcController
  match     'npc_index'         =>  'game/npc#npc'
  match     'npc_smithy'        =>  'game/npc#smithy'
  match     'npc_do_buy_new'    =>  'game/npc#do_buy_new'
  match     'npc_heal'          =>  'game/npc#heal'
  match     'npc_do_heal'       =>  'game/npc#do_heal'
  match     'npc_train'         =>  'game/npc#train'
  match     'npc_do_train'      =>  'game/npc#do_train'
  match     'npc_buy'           =>  'game/npc#buy'
  match     'npc_do_buy'        =>  'game/npc#do_buy'
  match     'npc_sell'          =>  'game/npc#sell'
  match     'npc_do_sell'       =>  'game/npc#do_sell'
    
  #ManagementController
  match     'mgmt_levels'       =>  'management/levels#index'
  match     'mgmt_levels_show'  =>  'management/levels#show'
  match     'mgmt_levels_new'   =>  'management/levels#new'
  match     'mgmt_levels_create'=>  'management/levels#create'
  match     'mgmt_levels_edit'  =>  'management/levels#edit'
  match     'mgmt_levels_update'=>  'management/levels#update'

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
  match     ':controller(/:action(/:id(.:format)))'
end
