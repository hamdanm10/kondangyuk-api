FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email     { Faker::Internet.unique.email }
    password  { 'Password12345!' }
    role      { :admin }
    is_active { true }

    trait :super_admin do
      role { :super_admin }
    end

    trait :designer do
      role { :designer }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
