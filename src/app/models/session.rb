class Session < ApplicationRecord
  belongs_to :account
  enum status: { normal: 0, suspended: 1 }
end
