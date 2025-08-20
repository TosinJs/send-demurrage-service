FactoryBot.define do
  factory :bill_of_lading do
    association :customer

    # Generate a number that's exactly 9 characters long (BL + 7 digits)
    sequence(:number) { |n| "BL#{n.to_s.rjust(7, '0')}"[0..8] }
    arrival_date { Date.current - rand(1..30).days }
    free_time_days { rand(5..14) }
    statut { 'active' }

    # Default container counts set to 0 to ensure deterministic behavior in tests.
    containers_20ft_dry_count     { 0 }
    containers_40ft_dry_count     { 0 }
    containers_20ft_reefer_count  { 0 }
    containers_40ft_reefer_count  { 0 }
    containers_20ft_special_count { 0 }
    containers_40ft_special_count { 0 }

    trait :overdue do
      arrival_date { Date.current - free_time_days.days - 1.day }
    end
  end
end
