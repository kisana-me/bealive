class Group < ApplicationRecord
  belongs_to :account

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2 }

  before_create :set_aid
end
