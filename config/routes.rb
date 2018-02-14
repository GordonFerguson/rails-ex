Rails.application.routes.draw do
  get 'prc2b/index'

  get 'prc2b/entry'

  get 'prc2b/admin'

  get 'prc2b/reader'

  get 'prc2b/super'

  resources :users
  get 'prc2b/index'
  root 'prc2b#index'
  resources :articles do
    resources :comments
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
