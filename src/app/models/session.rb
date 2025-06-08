class Session < ApplicationRecord
  belongs_to :account
  enum :status, { normal: 0, locked: 1 }
end
