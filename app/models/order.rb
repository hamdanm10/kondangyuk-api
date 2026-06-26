class Order < ApplicationRecord
  belongs_to :template
  belongs_to :marketplace
  has_one    :invitation, dependent: :destroy

  # The invitation is created/updated together with its order through the orders endpoint.
  # update_only keeps the single has_one invitation on update instead of building a new one.
  accepts_nested_attributes_for :invitation, update_only: true

  enum :status, { pending: "pending", working: "working", review: "review", completed: "completed" }

  validates :order_number, presence: true, uniqueness: { scope: :marketplace_id }

  def self.ransackable_attributes(_auth_object = nil)
    %w[order_number status template_id marketplace_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[invitation template marketplace]
  end
end
