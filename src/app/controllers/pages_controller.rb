class PagesController < ApplicationController

  def index
    @captures = Capture
      .is_normal
      .is_opened
      .is_captured
      .order(captured_at: :desc)
      .limit(10)
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
