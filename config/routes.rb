Rails.application.routes.draw do
  root 'application#server_status'

  resource :session
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :short_urls, only: [] do
        collection do
          post :encode
        end
      end

      get('short_urls/decode/:code', to: 'short_urls#decode', as: :decode_short_url, constraints: { code: /[^\/]+/ })

      namespace :auth do
        resources :sessions, only: [] do
          collection do
            post :create
          end
        end
      end
    end

    # Catch-all for unmatched API routes
    match '*path', to: 'v1/api#not_found', via: :all
  end
end
