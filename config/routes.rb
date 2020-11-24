Rails.application.routes.draw do
  
  # トップページ
  root 'static_pages#top'
  
  # ユーザー新規登録
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new' 
  post '/login', to: 'sessions#create' 
  delete '/logout', to: 'sessions#destroy' 
  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'get_commuting_list'
      patch 'monthapplies/applying_update'
    end
    resources :attendances, only: :update do
      member do
        get 'overtime_apply'
        patch 'update_overtime_apply'
      end
    end
    resources :monthapplies do
    end
    collection {post :import}
  end
  
  resources :bases do
    member do
      patch 'update_type'
    end
  end
  
end