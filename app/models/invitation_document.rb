class InvitationDocument < ApplicationRecord
  belongs_to :invitation
  has_many_attached :media

  validates :document, presence: true
end
