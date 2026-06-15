module InvitationDocuments
  class ShowService < BaseService
    def initialize(invitation_id:)
      @invitation_id = invitation_id
    end

    def call
      invitation = InvitationRepository.new.find_by_id_or_slug(@invitation_id)
      document   = InvitationDocumentRepository.new.find_by_invitation(invitation)
      ServiceResult.success({ document: document })
    end
  end
end
