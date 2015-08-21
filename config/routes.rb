Rails.application.routes.draw do
  resources :domains,     format: false
  resources :rate_limits, format: false
  resources :adapters,    format: false
  resources :extensions,  format: false
  resources :scripts,     format: false
  resources :feeds,       format: false
  resources :schemas,     format: false

  resources :pages,        format: false, only: [:show, :index]
  resources :documents,   format: false, only: [:show, :index]
end
