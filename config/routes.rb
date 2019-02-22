Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs' # PDF viewer

  resources :datasheet_selections, only: [:create, :destroy, :show] do
    resources :datasheets, only: [:index]
  end

  get 'home/index'

  put 'datasheet_categories', to: "datasheet_categories#update"
  put 'datasheet_categories/logo', to: "datasheet_categories#remove_logo"

  resources :datasheet_categories, only: [:index, :create, :destroy] do
    resources :datasheets, only: [:index, :create]
  end

  resources :datasheets, only: [:index, :create, :destroy]

  get 'materials/index'
  get 'about/index'

  get 'datasheet_process', to: "datasheet_process#show"
  post 'datasheet_process', to: "datasheet_process#processSelections"

  root 'home#index'
end
