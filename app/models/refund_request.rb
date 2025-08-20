class RefundRequest < ApplicationRecord
  self.readonly!

  validates :bill_of_lading_number, presence: true
end
