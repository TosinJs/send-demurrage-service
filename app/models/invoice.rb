class Invoice < ApplicationRecord
  belongs_to :bill_of_lading, primary_key: :number, foreign_key: :bill_of_lading_number, inverse_of: :invoices

  scope :overdue, -> { where.not(status: "paid").where("due_date < ?", Date.current) }

  validates :amount, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :reference, presence: true
  validates :bill_of_lading_number, presence: true
  validates :status, presence: true
  validates :invoiced_at, presence: true
end
