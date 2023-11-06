Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  # root path homepage
  root "home#index"

  # Home route
  get 'home', to: 'home#index', as: :home

  # Authentication routes
  scope do
    get '/sign-in', to: 'auth#sign_in_show', as: :sign_in_auth
    post '/sign-in', to: 'auth#sign_in_post', as: :sign_in_post_auth
    get 'sign-up', to: 'auth#sign_up_show', as: :sign_up_auth
    post 'sign-up', to: 'auth#sign_up_post', as: :sign_up_post_auth
    get 'validate-email', to: 'auth#validate_email', as: :validate_email_auth
    delete 'sign-out', to: 'auth#sign_out_delete', as: :sign_out_delete_auth
    get 'forgot-password', to: 'auth#forgot_password_show', as: :forgot_password_auth
    post 'forgot-password', to: 'auth#forgot_password_post', as: :forgot_password_post_auth
    get 'reset-password', to: 'auth#reset_password_show', as: :reset_password_auth
    patch 'reset-password', to: 'auth#reset_password_patch', as: :reset_password_patch_auth
  end

  # User routes
  resources :users, only: [:index] do
    member do
      get 'assign_role', to: 'users#assign_role', as: :assign_role
      patch 'assign_role', to: 'users#assign_role_patch', as: :assign_role_patch
    end
  end


  # Role routes
  resources :roles, only: [:index, :new, :create] do
    member do
      get 'assign_permissions', to: 'roles#assign_permissions', as: :assign_permissions
      patch 'assign_permissions', to: 'roles#assign_permissions_patch', as: :assign_permissions_patch
    end
  end

  # Permission routes
  resources :permissions

  # Category routes
  resources :categories

end
