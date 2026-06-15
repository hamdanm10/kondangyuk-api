class Template < ApplicationRecord
  belongs_to :created_by_user, class_name: "User"
  has_one    :template_document, dependent: :destroy
  has_one_attached :thumbnail

  has_many :template_themes, dependent: :destroy
  has_many :themes, through: :template_themes
  has_one  :template_tier, dependent: :destroy
  has_one  :tier, through: :template_tier

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_deleted?
    deleted_at.present?
  end
end
