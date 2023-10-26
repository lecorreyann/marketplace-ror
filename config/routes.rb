Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # root "user#sign_up_show"
  # root path homepage
  root "home#index"
  get 'home', to: 'home#index', as: :home
  get 'sign-in', to: 'users#sign_in_show', as: :users_sign_in
  post 'sign-in', to: 'users#sign_in_post', as: :users_sign_in_post
  get 'sign-up', to: 'users#sign_up_show', as: :users_sign_up
  post 'sign-up', to: 'users#sign_up_post', as: :users_sign_up_post
  get 'validate-email', to: 'users#validate_email', as: :users_validate_email
  delete 'sign-out', to: 'users#sign_out', as: :users_sign_out_delete
end
