class TemplateDocument < ApplicationRecord
  belongs_to :template

  validates :document, presence: true
end
