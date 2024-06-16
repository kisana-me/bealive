class Entry < ApplicationRecord
  enum status: { waiting: 0, accepted: 1 }
end