Rails.application.routes.draw do
  root 'pages#index'
  get 'tos' => 'pages#tos'
  get 'privacy_policy' => 'pages#privacy_policy'
  get 'contact' => 'pages#contact'
  resources :groups
  resources :comments
  resources :captures
  resources :sessions, except: [:new]
  get 'login' => 'sessions#new'
  delete 'logout' => 'sessions#logout'
  resources :accounts, except: [:new]
  get 'signup' => 'accounts#new'

  get "up" => "rails/health#show", as: :rails_health_check
end
