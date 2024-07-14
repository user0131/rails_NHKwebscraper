Rails.application.routes.draw do
   resources :articles, only: [:index, :show]
   post 'articles/scrape', to: 'articles#scrape', as: 'scrape_articles'
 end