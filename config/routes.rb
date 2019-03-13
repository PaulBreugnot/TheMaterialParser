Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs' # PDF viewer

  resources :datasheet_selections, only: [:create, :destroy, :show] do
    resources :datasheets, only: [:index]
  end

  put 'datasheet_categories', to: "datasheet_categories#update"
  put 'datasheet_categories/logo', to: "datasheet_categories#remove_logo"

  resources :datasheet_categories, only: [:index, :create, :destroy] do
    resources :datasheets, only: [:index, :create]
  end

  resources :datasheets, only: [:index, :create, :destroy]

  resources :materials, only: [:index]
  get 'materials/download_csv'
  get 'materials/available_components'
  post 'materials/search'
  post 'materials/create_selection'
  delete 'materials/delete_selection/:selection_uuid', to:'materials#delete_selection'

  get 'about/index'

  get 'datasheet_process', to: "datasheet_process#show"
  post 'datasheet_process', to: "datasheet_process#processSelections"
  get 'datasheet_process/download_csv'
  post 'datasheet_process/save_to_database'
  delete 'datasheet_process/ignore_material'

  root 'datasheets#index'
end
