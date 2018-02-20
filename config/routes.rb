Rails.application.routes.draw do

  # ========================================================
  # prc2b : test/debug pages: temporary
  get 'prc2b/index'
  get 'prc2b/entry'
  get 'prc2b/admin'
  get 'prc2b/reader'
  get 'prc2b/super'
  # ========================================================

  # ========================================================
  # prcis : anonymous access including front page with login
  #
  root 'prcis#index'
  get '/prcis/login' => 'prcis#login'
  get '/prcis/login/:id' => 'prcis#login'
  get '/prcis/logout' => 'prcis#logout'
  post '/prcis/prcis_authenticate_user_path' => 'prcis#lookup_user'
  get '/prcis/prcis_authenticate_user_path' => 'prcis#lookup_user'
  get '/prcis' => 'prcis#index'
  # ========================================================

  resources :users
  resources :articles do
    resources :comments
  end


  # ========================================================
  # admin : administrative pages
  get '/admin/index' => 'admin#index'
end
