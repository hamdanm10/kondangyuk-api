class Theme < ApplicationRecord
  validates :name, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def soft_deleted?
    deleted_at.present?
  end
end
