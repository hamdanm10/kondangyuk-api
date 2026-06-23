class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { admin: "admin", super_admin: "super_admin", designer: "designer" }

  normalizes :email, with: ->(email) { email.strip.downcase }

  scope :active, -> { where(is_active: true) }

  validates :full_name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :role, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[full_name is_active]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
