Rails.application.routes.draw do
   resources :articles, only: [:index, :show]
   root 'articles#index'
   post 'articles/scrape', to: 'articles#scrape'
end
