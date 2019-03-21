Rails.application.routes.draw do

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
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
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
      post 'stage_media'
      post 'stage_processing_event'
      post 'stage_cho'
    end
  end

  # for now, redirect to submission flow initial page when using browser reload or back button
  get '/submissions', to: redirect('/submissions/new')

  scope module: :morphosource do
    scope module: :my do
      get 'dashboard/my/downloads', action: :previous_downloads, controller: :cart_items, as: 'my_downloads'
      get 'dashboard/my/cart', action: :media_cart, controller: :cart_items, as: 'my_cart'
      post 'add_to_cart', action: :create, controller: :cart_items
      delete '/cart_items/:id', to: 'cart_items#destroy', as: 'remove_from_cart'
    end
  end

  # Physical Object show case pages
  scope module: :hyrax do
    get 'biological_specimens/:id', to: 'biological_specimens#showcase'
  end

  scope module: :hyrax do
    get 'cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
  end

end
