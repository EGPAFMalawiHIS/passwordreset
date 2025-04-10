Rails.application.routes.draw do
  # Root path
  root "dashboard#index"
  
  # Authentication
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # User registration
  get '/signup', to: 'users#new'
  resources :users, only: [:create, :index, :show] do
    collection do
      get :search
    end
  end
  
  # Dashboard
  get '/dashboard', to: 'dashboard#index'
  
  # Password Resets
  resources :password_resets, only: [:index, :new, :create, :show] do
    collection do
      get :search
    end
  end

  # Check phone
  get 'check_phone', to: 'application#check_phone'
  # Check phone
  get 'check_username', to: 'dashboard#check_username'
  
  # Reports
  resources :reports, only: [:index]
end