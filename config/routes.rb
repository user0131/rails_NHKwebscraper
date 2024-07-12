Rails.application.routes.draw do
   root 'articles#index'
   resources :articles
   post '/scrape', to: 'articles#scrape'
end
