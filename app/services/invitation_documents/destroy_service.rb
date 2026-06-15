module InvitationDocuments
  class DestroyService < BaseService
    def initialize(invitation_id:)
      @invitation_id = invitation_id
    end

    def call
      invitation = InvitationRepository.new.find_by_id_or_slug(@invitation_id)
      repo       = InvitationDocumentRepository.new
      document   = repo.find_by_invitation(invitation)
      repo.delete_document(document)
      ServiceResult.success({})
    end
  end
end
