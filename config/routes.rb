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
  
  # Reports
  resources :reports, only: [:index]
end