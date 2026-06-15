FactoryBot.define do
  factory :template do
    sequence(:slug) { |n| "template-#{n}" }
    sequence(:name) { |n| "Template #{n}" }
    association :created_by_user, factory: :user

    trait :with_document do
      after(:create) do |template|
        create(:template_document, template: template)
      end
    end
  end
end
