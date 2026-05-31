FactoryBot.define do
  factory :theme do
    name { Faker::Color.color_name.capitalize }
  end
end
