module ApplicationHelper
  def full_title(str)
    base = "BeAlive."
    return base if str.blank?
    "#{str} | #{base}"
  end
end
