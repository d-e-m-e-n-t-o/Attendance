Rails.application.routes.draw do
  
  # トップページ
  root 'static_pages#top'
  
  # ユーザー新規登録
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new' 
  post '/login', to: 'sessions#create' 
  delete '/logout', to: 'sessions#destroy' 
  
  resources :users
end