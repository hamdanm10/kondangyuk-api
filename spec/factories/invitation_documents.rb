FactoryBot.define do
  factory :invitation_document do
    association :invitation
    meta     { {} }
    document { "---\ntitle: Snapshot\n---\n# Hello" }
  end
end
