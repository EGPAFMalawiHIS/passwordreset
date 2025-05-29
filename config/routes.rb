Rails.application.routes.draw do
  # Root path
  root "dashboard#index"
  
  # Authentication
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # User registration
  get '/signup', to: 'users#new'
  resources :users, only: [:create, :index, :show, :edit,:update] do
    member do
      patch :toggle_activation 
    end
    collection do
      get :search
    end
  end
  
  # Dashboard
  get '/dashboard', to: 'dashboard#index'
  
  # Password Resets
  resources :password_resets, only: [:index, :new, :create, :show, :destroy] do
    collection do
      get :search
    end
  end

  # Check phone
  get 'check_phone', to: 'dashboard#check_phone'
  # Check phone
  get 'check_username', to: 'dashboard#check_username'
  # Barcode download
  get 'barcode_proxy', to: 'password_resets#barcode_proxy'
  
  # Reports
  resources :reports, only: [:index]
end