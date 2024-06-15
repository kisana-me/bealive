Rails.application.routes.draw do
  resources :invitations
  root 'pages#index'
  get 'tos' => 'pages#tos'
  get 'privacy_policy' => 'pages#privacy_policy'
  get 'contact' => 'pages#contact'
  post 'create_inquiry' => 'pages#create_inquiry'
  resources :groups
  resources :comments
  resources :captures
  resources :sessions, except: [:new]
  get 'login' => 'sessions#new'
  delete 'logout' => 'sessions#logout'
  resources :accounts, except: [:new]
  get 'signup' => 'accounts#new'

  get "up" => "rails/health#show", as: :rails_health_check

  # Error
  get '*not_found', to: 'application#routing_error'
  post '*not_found', to: 'application#routing_error'
end
