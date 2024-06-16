class Inquiry < ApplicationRecord
  validates :name,
    presence: true
  validates :address,  
    presence: true
  validates :subject,
    presence: true
  validates :content,
    presence: true
  enum status: { waiting: 0, done: 1 }
end
