Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  root "scores#index"

  namespace :api do
    resources :scores, only: [:index, :create] do
      member do
        get :whole_score
        patch :upsert_whole_score
      end
    end
  end
end
