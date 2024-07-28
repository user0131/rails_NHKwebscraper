Rails.application.routes.draw do
  # ルートページをarticlesコントローラーのindexアクションに設定する
  root 'articles#index'

  resources :articles, only: [:index, :show]
  post 'articles/scrape', to: 'articles#scrape', as: 'scrape_articles'
 end