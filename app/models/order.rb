class Order < ApplicationRecord
  belongs_to :template
  has_one    :invitation, dependent: :destroy

  enum :status, { pending: "pending", working: "working", review: "review", completed: "completed" }

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
