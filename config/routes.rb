Rails.application.routes.draw do
  root "graph/projects#index"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :graph do
    resources :projects, only: [:index, :show]
  end
end