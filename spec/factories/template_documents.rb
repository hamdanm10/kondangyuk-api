FactoryBot.define do
  factory :template_document do
    association :template
    meta     { {} }
    document { "---\ntitle: Sample\n---\n# Hello" }
  end
end
