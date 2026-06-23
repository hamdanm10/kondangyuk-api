FactoryBot.define do
  factory :template do
    sequence(:slug) { |n| "template-#{n}" }
    sequence(:name) { |n| "Template #{n}" }
    association :created_by_user, factory: :user

    transient do
      themes_count { 1 }
    end

    # A template requires a tier and at least one theme to be valid, so attach them
    # before save. Callers can override via the :tier / :themes / themes_count.
    after(:build) do |template, evaluator|
      template.tier ||= create(:tier)
      template.themes = create_list(:theme, evaluator.themes_count) if template.themes.empty?
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_document do
      after(:create) do |template|
        create(:template_document, template: template)
      end
    end

    trait :classified do
      after(:create) do |template|
        template.themes = create_list(:theme, 2)
        template.tier   = create(:tier)
      end
    end
  end
end
