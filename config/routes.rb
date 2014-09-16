Rails.application.routes.draw do


  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :controller => 'users'
  post 'comments/update_comment' => 'comments#update_comment'
  get '/' => "home#index"
  get '/home' => "home#index"
  get 'plans/odp/' => 'plans#odp'
  get 'plans/all' => 'plans#showall'
  get 'plans/stats/' => 'plans#stats'
  post 'plans/update_bounds' => 'plans#update_bounds'
  post 'plan_statuses/activate' => 'plan_statuses#activate'

  post 'polygons/update' => 'polygons#update'
  post 'polygons/create' => 'polygons#create'
  post 'polygons/delete' => 'polygons#delete'
  resources :user_polygons
  #resources :polygons, only: [:create, :destroy, :update]
  resources :plan_statuses
  resources :zones
  resources :statuses
  resources :plans
  resources :comments
  resources :ratings, only: [:create, :destroy]
  resources :likes, only: [:create, :destroy]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
