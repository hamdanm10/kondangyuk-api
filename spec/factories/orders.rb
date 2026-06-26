FactoryBot.define do
  factory :order do
    association :template
    association :marketplace
    sequence(:order_number) { |n| "ORD-#{n}" }
    status { :pending }

    # Every order is created together with its invitation through the orders endpoint, so model
    # this for specs that read order.invitation (show/update/index/delete).
    trait :with_invitation do
      after(:create) do |order|
        create(:invitation, order: order)
      end
    end
  end
end
