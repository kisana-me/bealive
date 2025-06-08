class Follow < ApplicationRecord
  enum :status, { normal: 0, locked: 1 }
end