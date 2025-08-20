class BillOfLading < ApplicationRecord
  belongs_to :customer, inverse_of: :bill_of_ladings
  has_many :invoices, foreign_key: :bill_of_lading_number, inverse_of: :bill_of_lading

  CONTAINER_COLUMNS = %i[
    containers_20ft_dry_count
    containers_40ft_dry_count
    containers_20ft_reefer_count
    containers_40ft_reefer_count
    containers_20ft_special_count
    containers_40ft_special_count
  ].freeze

  scope :overdue_today, -> { 
    where("DATE(arrival_date) + INTERVAL free_time_days DAY <= ?", Date.current)
      .where.not(free_time_days: nil)
  }

  # --- Validations ---
  validates :number, presence: true, uniqueness: true
  validates :arrival_date, presence: true
  validates :free_time_days, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates(*CONTAINER_COLUMNS, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true)

  # Returns total container count for demurrage calculation.
  def containers_total
    CONTAINER_COLUMNS.sum { |col| self[col].to_i }
  end
end
