class Invitation < ApplicationRecord
  enum status: { normal: 0, suspended: 1 }
  belongs_to :account
  has_many :accounts
end
