FactoryBot.define do
  factory :invoice do
    association :bill_of_lading

    reference { SecureRandom.hex(5) }
    bill_of_lading_number { bill_of_lading.number }
    amount { rand(100..10_000) }
    currency { "USD" }
    due_date { Time.current.to_date + 15.days }
    status { %w[open paid cancelled].sample }
  end
end
