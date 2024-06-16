class PagesController < ApplicationController
  def index
    if @current_account
      @captures = Capture.where(sender: @current_account, deleted: false).limit(10).order(created_at: :desc)
    end
  end

  def tos
  end

  def privacy_policy
  end

  def contact
    @inquiry = Inquiry.new
    @problem, session[:answer] = generate_random_problem
  end

  def create_inquiry
    @inquiry = Inquiry.new(inquiry_params)
    if session[:answer].to_i != params[:answer].to_i
      @problem, session[:answer] = generate_random_problem
      flash.now[:alert] = '解答が間違っています'
      render 'contact'
      return
    end
    @inquiry.uuid = SecureRandom.uuid
    if @inquiry.save
      redirect_to root_path, notice: "送信しました。受付ID:#{@inquiry.uuid}"
    else
      @problem, session[:answer] = generate_random_problem
      render :contact
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :address, :subject, :content)
  end
end
