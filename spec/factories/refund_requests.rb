FactoryBot.define do
  factory :refund_request do
    sequence(:bill_of_lading_number) { |n| "BL#{n.to_s.rjust(8, '0')}" }
    requested_amount { rand(50..500) }
    status { "PENDING" }
  end
end
