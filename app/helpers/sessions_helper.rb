module SessionsHelper
  
  # 渡されたユーザーオブジェクトでログイン
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 現在ログイン中のユーザーがいる場合オブジェクトを返します。
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  
  # 現在ログイン中のユーザーがいればtrue、そうでなければfalseを返します。
  def logged_in?
    current_user.present?
  end
end

# sessionメソッド
  # ハッシュに入れられた値を自動で暗号化し、ユーザーのブラウザー内にある一時的cookiesに保存する。
  # 暗号化前の値を取得する場合は、session[取得したい値のハッシュ]と記述する。