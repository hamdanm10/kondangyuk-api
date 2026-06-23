class Template < ApplicationRecord
  belongs_to :created_by_user, class_name: "User"
  has_one    :template_document, dependent: :destroy
  has_one_attached :thumbnail

  has_many :template_themes, dependent: :destroy
  has_many :themes, through: :template_themes
  has_one  :template_tier, dependent: :destroy
  has_one  :tier, through: :template_tier

  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  validates :slug, presence: true, uniqueness: true,
                   format: { with: SLUG_FORMAT,
                             message: "must be lowercase alphanumeric words separated by single hyphens" }
  validates :name, presence: true

  validate :tier_must_be_present
  validate :must_have_at_least_one_theme

  scope :active, -> { where(deleted_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name slug]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[themes tier]
  end

  def soft_deleted?
    deleted_at.present?
  end

  private

  def tier_must_be_present
    errors.add(:tier, "must be present") if tier.blank?
  end

  def must_have_at_least_one_theme
    errors.add(:themes, "must have at least one theme") if themes.empty?
  end
end
