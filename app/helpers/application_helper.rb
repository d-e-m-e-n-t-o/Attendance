module ApplicationHelper
  # タグのタイトルを返すメソッドです。
  def full_title(page_name = '')
    base_title = 'AttendanceApp'
    if page_name.empty?
      base_title
    else
      page_name + ' | ' + base_title
    end
  end
  class << self
    attr_accessor :weeks
  end

  ApplicationHelper.weeks = %w[日 月 火 水 木 金 土]
end
