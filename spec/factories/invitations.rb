FactoryBot.define do
  factory :invitation do
    association :order
    sequence(:slug) { |n| "invitation-#{n}" }
    sequence(:name) { |n| "Invitation #{n}" }

    trait :published do
      published_at { 1.day.ago }
    end

    trait :expired do
      published_at { 2.days.ago }
      expires_at   { 1.day.ago }
    end

    trait :with_document do
      after(:create) do |invitation|
        create(:invitation_document, invitation: invitation)
      end
    end

    trait :with_thumbnail do
      after(:create) do |invitation|
        invitation.thumbnail.attach(
          io: Rails.root.join("spec/fixtures/files/sample.png").open,
          filename: "sample.png",
          content_type: "image/png"
        )
      end
    end
  end
end
