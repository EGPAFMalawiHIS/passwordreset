Rails.application.routes.draw do
  # Root path
  root 'home#index'

  # Authentication routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Registration routes
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  # Dashboard
  get 'dashboard', to: 'dashboard#index'

  # Reports
  get 'reports/dashboard', to: 'reports#dashboard'

  # Reset transactions
  resources :reset_transactions do
    collection do
      get 'reports'
      get 'export_csv'
      get 'export_pdf'
      get 'export_excel'
    end
  end

  # API routes
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'authentication#login'
      resources :reset_transactions, only: [:index, :show, :create]
    end
  end
end

