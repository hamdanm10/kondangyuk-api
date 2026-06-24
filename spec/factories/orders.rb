FactoryBot.define do
  factory :order do
    association :template
    association :marketplace
    sequence(:order_number) { |n| "ORD-#{n}" }
    status { :pending }
  end
end
