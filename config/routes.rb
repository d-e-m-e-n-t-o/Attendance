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
      get 'attendances/edit_days_apply'
      get 'attendances/edit_days_applying'
      get 'attendances/attendances_applying_update_index'
      patch 'attendances/update_edit_days_applying'
      patch 'attendances/update_edit_days_apply'
      get 'attendances/over_applying'
      patch 'attendances/update_over_applying'
      get 'get_commuting_list'
      patch 'monthapplies/applying_update'
      get 'attendances/approval_log'
    end
    resources :attendances do
      member do
        get 'over_apply'
        get 'edit_day_reapply'
        patch 'update_over_apply'
        patch 'destroy_edit_days_apply'
        patch 'destroy_over_apply'
      end
    end
    resources :monthapplies do
      member do
        patch 'destroy_month_apply'
      end
    end
    collection {post :import}
  end
  
  resources :bases do
    member do
      patch 'update_type'
    end
  end
  
end