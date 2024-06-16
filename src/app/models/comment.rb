class Comment < ApplicationRecord
  belongs_to :account
  belongs_to :capture
  enum status: { normal: 0, suspended: 1 }
end
