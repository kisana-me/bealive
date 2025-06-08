class PagesController < ApplicationController

  def index
    @captures = Capture.where(visibility: :public, status: :done, deleted: false).limit(30).order(created_at: :desc)
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
