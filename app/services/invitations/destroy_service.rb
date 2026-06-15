module Invitations
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo       = InvitationRepository.new
      invitation = repo.find_by_id_or_slug(@id)
      repo.delete_invitation(invitation)
      ServiceResult.success({})
    end
  end
end
