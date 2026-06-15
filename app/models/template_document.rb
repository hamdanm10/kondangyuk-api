class TemplateDocument < ApplicationRecord
  belongs_to :template
  has_many_attached :media

  validates :document, presence: true
end
