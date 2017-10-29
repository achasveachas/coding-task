Rails.application.routes.draw do

  root 'batches#index'

  resources :batches, only: [:index, :show, :create]

end
