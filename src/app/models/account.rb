class Account < ApplicationRecord
  has_secure_password
  has_many :sender, class_name: 'Capture', foreign_key: 'sender_id'
  has_many :receiver, class_name: 'Capture', foreign_key: 'receiver_id'
end
