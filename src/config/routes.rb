Rails.application.routes.draw do

  # pages
  root "pages#index"
  get "terms-of-service" => "pages#terms_of_service"
  get "privacy-policy" => "pages#privacy_policy"
  get "contact" => "pages#contact"

  # accounts
  resources :accounts, only: [:index, :show], param: :name_id do
    member do
      get :followers
      get :following
    end
  end

  # follows
  namespace :follows do
    post "request", to: "frequest"
    delete "withdraw"
    patch "accept"
    delete "decline"
  end

  # sessions
  get "sessions/start"
  post "sessions/oauth"
  get "sessions/callback"
  delete "signout" => "sessions#signout"
  resources :sessions, except: [:new, :create]

  # signup
  get "signup" => "signup#new"
  post "signup" => "signup#create"

  # settings
  get "settings" => "settings#index"
  get "settings/account" => "settings#account"
  patch "settings/account" => "settings#post_account"
  delete "settings/leave" => "settings#leave"

  resources :captures do
    member do
      get "capture"
      post "capture", to: "post_capture"
    end
  end

  # resources :groups
  # resources :comments

  # others
  get "up" => "rails/health#show", as: :rails_health_check

  # errors
  get "*not_found", to: "application#routing_error"
  post "*not_found", to: "application#routing_error"

end
