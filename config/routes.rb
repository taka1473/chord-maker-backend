Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  root "scores#index"

  namespace :api do
    get "users/me", to: "users#me"
    patch "users/me", to: "users#update_me"

    resources :scores, only: [ :index, :create, :destroy ] do
      member do
        get :whole_score
        patch :upsert_whole_score
        patch :claim
      end
    end

    namespace :me do
      resources :scores, only: [ :index ]
    end

    namespace :admin do
      resources :users, only: [ :index, :destroy ]
      resources :scores, only: [ :index, :destroy ] do
        member { patch :unpublish }
        collection { post :import }
      end
      resources :tags, only: [ :index, :destroy ]
    end
  end
end
