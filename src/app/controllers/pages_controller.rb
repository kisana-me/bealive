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
  end
end
