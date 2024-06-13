class ApplicationController < ActionController::Base
  include SessionManagement
  before_action :set_current_account

  unless Rails.env.development?
    rescue_from Exception,                      with: :render_500
    rescue_from ActiveRecord::RecordNotFound,   with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def render_404
    render 'errors/404', status: :not_found
  end
  def render_500
    render 'errors/500', status: :internal_server_error
  end
  def logged_in_account
    unless @current_account
      flash[:alert] = "ログインしてください"
      redirect_to login_path
    end
  end
  def logged_out_account
    unless !@current_account
      flash[:alert] = "ログイン済みです"
      redirect_to root_path
    end
  end
  def set_current_account
    @current_account = current_account
  end
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  def redirect_back_or(default: root_path)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
