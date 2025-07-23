class Session < ApplicationRecord
  belongs_to :account
  attribute :meta, :json, default: {}
  enum :status, { normal: 0, locked: 1 }
  before_create :set_aid
end
