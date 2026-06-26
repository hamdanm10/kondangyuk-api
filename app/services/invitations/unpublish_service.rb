module Invitations
  class UnpublishService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo       = InvitationRepository.new
      invitation = repo.find_by_id_or_slug(@id)
      invitation = repo.set_published(invitation, published_at: nil)
      ServiceResult.success({ invitation: invitation })
    end
  end
end
