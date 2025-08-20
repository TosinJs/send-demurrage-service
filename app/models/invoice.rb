class Invoice < ApplicationRecord
  # Statuses considered not yet settled.
  OPEN_STATUSES = %w[open init pending].freeze
  belongs_to :bill_of_lading, primary_key: :number, foreign_key: :bill_of_lading_number, inverse_of: :invoices

  scope :overdue, -> { where(status: OPEN_STATUSES).where("due_date < ?", Date.current) }

  validates :amount, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :reference, presence: true
  validates :bill_of_lading_number, presence: true
  validates :status, presence: true
end
