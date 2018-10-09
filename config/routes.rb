Rails.application.routes.draw do
  get 'errors/not_found'

  get 'errors/internal_server_error'

  root to: 'pages#home'

  resources :suggestions, only: [:index, :update]
  resources :businesses, only: [:show, :new, :create, :edit, :update] do
    resources :notes, only: [:create]
  end

  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations",
    confirmations: "confirmations"
  }

  authenticated :user do
    root 'suggestions#index', as: :authenticated_root
  end

  get '/users', to: 'pages#welcome', as: :user_root # creates user_root_path
  get '/welcome', to: 'pages#welcome'
  get '/assign_business', to: 'pages#assign_business'
  get '/search', to: 'pages#search'
  get '/my_business', to: 'businesses#my_business'
  get '/my_business/edit', to: 'businesses#edit'
  get '/matched_business', to: 'suggestions#matched_business'
  get '/hail_mary', to: 'suggestions#hail_mary'
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
