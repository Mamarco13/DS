Rails.application.routes.draw do
  resources :lenguajes do
    resources :palabras, only: [:index, :create]
    post 'buscar', on: :member
  end

  resources :palabras, only: [:show, :update, :destroy]
end
