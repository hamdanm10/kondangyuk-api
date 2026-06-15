class Template < ApplicationRecord
  belongs_to :created_by_user, class_name: "User"
  has_one    :template_document, dependent: :destroy

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_deleted?
    deleted_at.present?
  end
end
