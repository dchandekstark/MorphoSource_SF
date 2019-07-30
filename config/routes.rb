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
  
  get '/submissions', to: 'submissions#new'
  # Redirect to submission flow initial page when using browser reload or back button
  get '/submissions/stage_biological_specimen', to: redirect('/submissions/new')
  get '/submissions/stage_device', to: redirect('/submissions/new')
  get '/submissions/stage_imaging_event', to: redirect('/submissions/new')
  get '/submissions/stage_institution', to: redirect('/submissions/new')
  get '/submissions/stage_device_institution', to: redirect('/submissions/new')
  get '/submissions/stage_media', to: redirect('/submissions/new')
  get '/submissions/stage_processing_event', to: redirect('/submissions/new')
  get '/submissions/stage_cho', to: redirect('/submissions/new')
  get '/submissions/stage_taxonomy', to: redirect('/submissions/new')


  scope module: :morphosource do
    scope module: :my do
      get 'dashboard/my/downloads', action: :previous_downloads, controller: :cart_items, as: 'my_downloads'
      get 'dashboard/my/cart', action: :media_cart, controller: :cart_items, as: 'my_cart'
      post 'add_to_cart', action: :create, controller: :cart_items
      post 'batch_create_items', action: :batch_create, controller: :cart_items
      delete '/cart_items', action: :batch_destroy, controller: :cart_items, as: 'batch_destroy_items'
      get 'download_items', action: :download, controller: :cart_items, as: 'download_items'
    end
  end
end
