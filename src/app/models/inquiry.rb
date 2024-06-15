class Inquiry < ApplicationRecord
  validates :name,
    presence: true
  validates :address,  
    presence: true
  validates :subject,
    presence: true
  validates :content,
    presence: true
end
