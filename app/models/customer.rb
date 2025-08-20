class Customer < ApplicationRecord
  has_many :bill_of_ladings, inverse_of: :customer

  validates :name, presence: true
  validates :code, uniqueness: true, allow_nil: true
end
