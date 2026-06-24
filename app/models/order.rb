class Order < ApplicationRecord
  belongs_to :template
  belongs_to :marketplace
  has_one    :invitation, dependent: :destroy

  enum :status, { pending: "pending", working: "working", review: "review", completed: "completed" }

  validates :order_number, presence: true, uniqueness: { scope: :marketplace_id }
end
