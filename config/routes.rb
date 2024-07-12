Rails.application.routes.draw do
  get 'articles/index'
  get 'static_pages/home'
  root "static_pages#home"
end
