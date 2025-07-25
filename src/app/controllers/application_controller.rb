class ApplicationController < ActionController::Base
  include ErrorsManagement
  include SessionManagement

  before_action :current_account
  before_action :set_current_attributes

  helper_method :admin?

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def require_signin
    return if @current_account
    store_location
    flash[:alert] = "サインインしてください"
    redirect_to root_path
  end

  def require_signout
    return unless @current_account
    flash[:alert] = "サインイン済みです"
    redirect_to root_path
  end

  def require_admin
    render_404 unless admin?
  end

  def admin?
    @current_account&.meta["roles"]&.include?("admin")
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def redirect_back_or(default = root_path)
    redirect_to(session.delete(:forwarding_url) || default)
  end

  def set_current_attributes
    Current.account = @current_account
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
  end
end
