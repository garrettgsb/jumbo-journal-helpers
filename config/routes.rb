Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#home'

  # Users Stuff
  get '/users', to: 'users#index'
  get '/users/new', to: 'users#new'
  get '/users/:id', to: 'users#show'

  post '/users', to: 'users#create'

  # Sessions Stuff - Are these RESTful?
  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'
  post '/sessions', to: 'sessions#create'
end
