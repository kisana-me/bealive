class PagesController < ApplicationController

  def index
    @captures = Capture
      .where(visibility: :public, status: :done, deleted: false)
      .limit(30)
      .order(captured_at: :desc)
      .includes(:sender, :receiver)
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
