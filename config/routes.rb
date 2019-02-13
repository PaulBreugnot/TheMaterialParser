Rails.application.routes.draw do

  resources :datasheet_selections, only: [:create, :destroy] do
    resources :datasheets, only: [:index]
  end


  get 'home/index'

  resources :datasheet_categories, only: [:index, :create] do
    resources :datasheets, only: [:index, :create]
  end

  resources :datasheets, only: [:index, :create, :destroy]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'materials/index'
  get 'about/index'

  root 'home#index'
end
