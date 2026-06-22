class Tier < ApplicationRecord
  validates :name,  presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(deleted_at: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def soft_deleted?
    deleted_at.present?
  end
end
