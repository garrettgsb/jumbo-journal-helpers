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

  # Journals Stuff - What routes does this generate? What routes DOESN'T it generate? (Hint: `rails routes`/`rake routes`)
  resources :journals, except: [:update, :destroy] do
    # Entries Stuff - Entries must belong to a journal when they are created, so these routes are nested inside of Journals.
    resources :entries, only: [:new, :create]
  end

  # Also Entries - Except for new and create, other Entries stuff treats an entry as a top-level resource.
  # (And we don't use index at all-- Instead, each journal page lists its entries)
  resources :entries, except: [:new, :create, :index]
end
