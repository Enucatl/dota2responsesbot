Rails.application.routes.draw do
  post 'show', to: 'responses#show'
  get 'show', to: 'responses#show'
  post 'telegram', to: 'telegram#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
