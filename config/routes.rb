Rails.application.routes.draw do
  resources :domains,     format: false
  resources :rate_limits, format: false
  resources :extensions,  format: false
  resources :scripts,     format: false
  resources :feeds,       format: false
  resources :schemas,     format: false
  resources :mappings,    format: false
  resources :documents,   format: false, only: [:show, :index]

  resources :adapters, format: false do
    resources :documents, format: false, only: [:index]
  end

  resources :pages, format: false, only: [:show, :index] do
    resources :documents, format: false, only: [:index]
  end

  post  "scrapes"  => "scrapes#build"
end
