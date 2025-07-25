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
    unless @current_account
      flash[:alert] = "サインインしてください"
      redirect_to root_path
    end
  end

  def require_signout
    unless !@current_account
      flash[:alert] = "サインイン済みです"
      redirect_to root_path
    end
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

  def redirect_back_or(default: root_path)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def generate_random_problem
    num1 = rand(100)
    num2 = rand(1..10)
    operator = %w[+ - * /].sample
    if operator == "/"
      num1 = num1 - (num1 % num2)
    end
    problem = "#{num1} #{operator} #{num2}"
    [problem, eval(problem)]
  end

  def set_current_attributes
    Current.account = @current_account
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
  end
end
