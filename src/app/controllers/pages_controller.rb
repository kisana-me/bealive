class PagesController < ApplicationController

  def index
    if @current_account
      @captures = Capture.where(sender: @current_account, deleted: false).limit(10).order(created_at: :desc)
    end
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
