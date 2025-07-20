Rails.application.routes.draw do
  root "scores#index"
  resources :scores, only: [:index, :show]
end
