class PagesController < ApplicationController

  def index
    @captures = Capture.captured.where(visibility: :public).limit(10)
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
