class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'Account'
  belongs_to :followed, class_name: 'Account'

  validates :follower_id, uniqueness: { scope: :followed_id, message: 'は既にこのアカウントをフォローしています' }
  validates :followed_id, uniqueness: { scope: :follower_id, message: 'は既にこのアカウントにフォローされています' }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:base, '自分自身をフォローすることはできません')
    end
  end
end
