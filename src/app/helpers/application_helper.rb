module ApplicationHelper
  def full_title(str)
    base = 'BeAlive.'
    return base if str.blank?
    "#{str} | #{base}"
  end
  def link_to(name = nil, options = nil, html_options = nil, &block)
    html_options ||= {}
    html_options[:data] ||= {}
    html_options[:data][:turbo_prefetch] = false unless html_options[:data].key?(:turbo_prefetch)
    super(name, options, html_options, &block)
  end
end
