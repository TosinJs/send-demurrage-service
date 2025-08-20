FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:code) { |n| "CUST#{n.to_s.rjust(4, '0')}" }
  end
end
