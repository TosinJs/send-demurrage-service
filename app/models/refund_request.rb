class RefundRequest < ApplicationRecord
  # Make all instances of this model read-only
  def readonly?
    true
  end

  validates :bill_of_lading_number, presence: true
end
