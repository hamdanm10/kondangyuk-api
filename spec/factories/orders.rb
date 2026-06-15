FactoryBot.define do
  factory :order do
    association :template
    price  { 150_000.00 }
    status { :pending }
  end
end
