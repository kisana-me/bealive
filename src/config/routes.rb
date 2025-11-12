Rails.application.routes.draw do
  root "pages#index"

  # Pages
  get "terms-of-service" => "pages#terms_of_service"
  get "privacy-policy" => "pages#privacy_policy"
  get "contact" => "pages#contact"

  # Sessions
  get "sessions/start"
  delete "signout" => "sessions#signout"
  resources :sessions, except: [:new, :create], param: :aid

  # Signup
  get "signup" => "signup#new"
  post "signup" => "signup#create"

  # OAuth
  post "oauth/start" => "oauth#start"
  get "oauth/callback" => "oauth#callback"
  post "oauth/fetch" => "oauth#fetch"

  # accounts
  resources :accounts, only: :index
  get "@:name_id", to: "accounts#show", as: :account
  get "@:name_id/followers", to: "accounts#following", as: :followers_account
  get "@:name_id/following", to: "accounts#following", as: :following_account

  # follows
  namespace :follows do
    post "request", to: "frequest"
    delete "withdraw"
    patch "accept"
    delete "decline"
  end

  # captures
  get "captures/sended"
  get "captures/received"
  get "captures/load_more"
  resources :captures, param: :aid do
    member do
      get "capture"
      post "capture", to: "post_capture"
    end
  end

  resources :images, only: [:new, :create], param: :aid
  # resources :groups
  # resources :comments

  # Settings
  get "settings" => "settings#index"
  get "settings/account" => "settings#account"
  get "settings/icon" => "settings#icon"
  patch "settings/account" => "settings#post_account"
  delete "settings/leave" => "settings#leave"

  # Others
  get "up" => "rails/health#show", as: :rails_health_check

  # Errors
  match "*path", to: "application#routing_error", via: :all
end
