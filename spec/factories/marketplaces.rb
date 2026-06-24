FactoryBot.define do
  factory :marketplace do
    name { Faker::Company.unique.name }
  end
end
