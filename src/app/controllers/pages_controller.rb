class PagesController < ApplicationController

  def index
    @captures = Capture
      .where.not(captured_at: nil)
      .where(visibility: :public, deleted: false)
      .limit(30)
      .order(captured_at: :desc)
      .includes(:front_photo, :back_photo, sender: :icon, receiver: :icon)
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def contact
  end

end
