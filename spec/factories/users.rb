FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    password { 'Password12345!' }
    role     { :admin }

    trait :super_admin do
      role { :super_admin }
    end
  end
end
