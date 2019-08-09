Rails.application.routes.draw do

  # Physical Object show case pages
  scope module: :hyrax do
    get 'biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    get 'media/:id', to: 'media#showcase'
    # redirect the default BSO/CHO view to showcase view, except for certain action (e.g. new)
    get 'concern/biological_specimens/new', to: 'biological_specimens#new'
    get 'concern/cultural_heritage_objects/new', to: 'cultural_heritage_objects#new'
    get 'concern/biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'concern/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    get 'concern/parent/:parent_id/biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'concern/parent/:parent_id/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    # redirect the default media view to showcase view, except for certain action (e.g. new)
    get 'concern/media/new', to: 'media#new'
    get 'concern/media/zip', to: 'media#zip'
    get 'concern/media/:id', to: 'media#showcase'
    get 'concern/parent/:parent_id/media/:id', to: 'media#showcase'
    # setup temp routes for the default views (for debugging)
    # remove them later if no longer needed
    get 'concern/media/show/:id', to: 'media#show'
    get 'concern/biological_specimens/show/:id', to: 'biological_specimens#show'
    get 'concern/cultural_heritage_objects/show/:id', to: 'cultural_heritage_objects#show'
  end

  require "resque_web"
  mount ResqueWeb::Engine => "/queues"

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  mount Qa::Engine => '/authorities'

  scope module: :morphosource do
    resources :downloads, only: :show
  end

  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'

  namespace :hyrax, path: :concern do
    namespaced_resources 'media' do
      collection do
        get :zip, action: :zip
      end
    end
  end

  # Permissions routes
  namespace :hyrax, path: :concern do
    resources :permissions, only: [] do
      member do
        get :copy_access
        get :copy
      end
    end
  end

  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new


  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :submissions, only: [ :new, :create ] do
    collection do
      post 'stage_biological_specimen'
      post 'stage_device'
      post 'stage_imaging_event'
      post 'stage_institution'
      post 'stage_device_institution'
      post 'stage_media'
      post 'stage_processing_event'
      post 'stage_cho'
      post 'stage_taxonomy'
      # for new work modal
      get 'new_institution'
      post 'new_institution_submit'
      get 'new_taxonomy'
      post 'new_taxonomy_submit'
    end
  end
  
  # Route to flow initial page when using browser reload or back button
  get '/submissions/stage_biological_specimen', to: 'submissions#new'
  get '/submissions/stage_device', to: 'submissions#new'
  get '/submissions/stage_imaging_event', to: 'submissions#new'
  get '/submissions/stage_institution', to: 'submissions#new'
  get '/submissions/stage_device_institution', to: 'submissions#new'
  get '/submissions/stage_media', to: 'submissions#new'
  get '/submissions/stage_processing_event', to: 'submissions#new'
  get '/submissions/stage_cho', to: 'submissions#new'
  get '/submissions/stage_taxonomy', to: 'submissions#new'
  get '/submissions', to: 'submissions#new'

  scope module: :morphosource do
    scope module: :my do

      # cart items
      post 'add_to_cart', action: :create, controller: :cart_items

      # media cart
      get 'dashboard/my/cart', action: :index, controller: :media_carts, as: 'my_cart'
      get 'download_items', action: :download, controller: :media_carts, as: 'download_items'
      delete 'remove_from_cart', action: :destroy, controller: :media_carts, as: 'remove_items'

      # downloads
      get 'dashboard/my/downloads', action: :index, controller: :downloads, as: 'my_downloads'
      post 'batch_create_items', action: :batch_create, controller: :downloads

      # requests
      get 'dashboard/my/requests', action: :index, controller: :requests, as: 'my_requests'
      put 'request_item', action: :request_item, controller: :requests, as: 'request_item'
      get 'request_again', action: :request_again, controller: :requests, as: 'request_again'
      put 'cancel_request', action: :cancel_request,
      controller: :requests, as: 'cancel_request'

      # request manager
      get 'dashboard/my/request_manager', action: :index, controller: :request_managers, as: 'request_manager'
      put 'approve_download', action: :approve_download, controller: :request_managers, as: 'approve_download'
      put 'clear_request', action: :clear_request, controller: :request_managers, as: 'clear_request'
      put 'deny_download', action: :deny_download, controller: :request_managers, as: 'deny_download'
    end
  end
end
