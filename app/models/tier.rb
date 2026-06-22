class Tier < ApplicationRecord
  # Matches the DB column decimal(precision: 8, scale: 2) — max 6 integer digits.
  MAX_PRICE = 999_999.99

  validates :name,  presence: true
  validates :price, presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: MAX_PRICE }

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
