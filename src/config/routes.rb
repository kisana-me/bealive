Rails.application.routes.draw do
  resources :invitations
  root 'pages#index'
  get 'terms' => 'pages#terms'
  get 'privacy' => 'pages#privacy'
  get 'contact' => 'pages#contact'
  post 'create_inquiry' => 'pages#create_inquiry'
  resources :groups
  resources :comments
  resources :captures

  # session
  get "sessions/start"
  post "sessions/oauth"
  get "sessions/callback"
  delete 'logout' => 'sessions#logout'
  resources :sessions, except: [:new, :create]

  # signup
  get "signup" => "signup#new"
  post "signup" => "signup#create"

  # account
  resources :accounts, except: [:new]
  # get 'signup' => 'accounts#new'
  post 'search_account' => 'accounts#search_account'

  get "up" => "rails/health#show", as: :rails_health_check

  # Error
  get '*not_found', to: 'application#routing_error'
  post '*not_found', to: 'application#routing_error'
end
