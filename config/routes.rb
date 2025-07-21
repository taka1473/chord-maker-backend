Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  root "scores#index"

  namespace :api do
    resources :scores, only: [:index, :show]
  end
end
