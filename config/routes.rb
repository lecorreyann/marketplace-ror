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
  get 'forgot-password', to: 'users#forgot_password_show', as: :users_forgot_password
  post 'forgot-password', to: 'users#forgot_password_post', as: :users_forgot_password_post
  get 'reset-password', to: 'users#reset_password_show', as: :users_reset_password
  patch 'reset-password', to: 'users#reset_password_patch', as: :users_reset_password_patch
end
