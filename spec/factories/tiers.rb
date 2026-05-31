FactoryBot.define do
  factory :tier do
    sequence(:name) { |n| "Tier #{n}" }
    price { 99_000.00 }
  end
end
