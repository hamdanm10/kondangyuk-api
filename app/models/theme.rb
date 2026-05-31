class Theme < ApplicationRecord
  validates :name, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_deleted?
    deleted_at.present?
  end
end
