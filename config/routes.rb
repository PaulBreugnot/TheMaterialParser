Rails.application.routes.draw do
  get 'home/index'
  get 'datasheet_categories/index'
  get 'datasheet_categories/create'

  resources :datasheet_categories, only: [:index, :create] do
    resources :datasheets, only: [:index, :create]
  end

  get 'datasheets/index'
  get 'datasheets/create'
  get 'datasheets/destroy'

  resources :datasheets, only: [:index, :create]

  get 'materials/index'
  get 'about/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
end
