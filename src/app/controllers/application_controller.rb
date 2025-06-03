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
      flash[:alert] = "サインインしてください"
      redirect_to root_path
    end
  end
  def logged_out_account
    unless !@current_account
      flash[:alert] = "サインイン済みです"
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
  def generate_random_problem
    num1 = rand(100)
    num2 = rand(1..10)
    operator = %w[+ - * /].sample
    if operator == '/'
      num1 = num1 - (num1 % num2)
    end
    problem = "#{num1} #{operator} #{num2}"
    [problem, eval(problem)]
  end
  def admin_account
    return if @current_account.meta && @current_account.meta['admin'] == true
    return render_404
  end
end
