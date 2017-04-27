Rails.application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => "/sidekiq"
  
  # Root
  root 'static_pages#index'
  match 'no_access' => 'static_pages#no_access', via: [:get]

  # Devise
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout' }
  devise_scope :user do
    put 'users' => 'devise/registrations#update', as: 'user_registration'
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
  end

  # Resources
  resources :nations, except: [:show, :edit, :update, :destroy] do
    member do
      post 'reconnect'
      delete 'disconnect'
      post 'sync'
    end
  end

  resources :users, only: [:new, :create, :index, :destroy] do
    member do
      match 'approve' => 'users#approve', via: [:get, :put]
      put 'make_admin'
      match 'receive_notification' => 'users#receive_notification', via: [:put]
    end
    collection do
      get 'admins'
      match 'request_access' => 'users#request_access', via: [:get]
      match 'join' => 'users#join', via: [:post]
    end
  end

  resources :events, only: [:index] do
    # Events import
    collection do
      get 'imports'
      get 'imported'
      match 'imported/:id/logs' => 'events#logs', via: [:get], as: 'imported_log'
      post 'import', to: 'events#import'
    end
  end

  # Endpoints
  match '/endpoints/create_event', to: 'endpoints#create_event', via: :post

  # OAuth
  match ENV['OAUTH_REDIRECT_PATH'], to: 'nations#oauth', via: :get

end
