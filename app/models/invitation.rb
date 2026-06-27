class Invitation < ApplicationRecord
  belongs_to :order
  has_one    :invitation_document, dependent: :destroy
  has_one_attached :thumbnail

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(deleted_at: nil) }
  scope :published, lambda {
    active.where.not(published_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current)
  }

  def published?
    published_at.present? && (expires_at.nil? || expires_at > Time.current)
  end

  def soft_deleted?
    deleted_at.present?
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name slug]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
