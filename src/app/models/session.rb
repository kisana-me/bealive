class Session < ApplicationRecord
  belongs_to :account
  enum :status, { normal: 0, locked: 1 }

  def self.find_by_token(token)
    lookup = new.generate_lookup(token)
    record = find_by("lookup": lookup, status: 0, deleted: false)
    return nil unless record
    digest = record.send("digest")
    return nil unless BCrypt::Password.new(digest).is_password?(token)
    record
  end
end
