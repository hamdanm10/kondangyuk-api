module InvitationDocuments
  class UpdateService < BaseService
    def initialize(invitation_id:, params:)
      @invitation_id = invitation_id
      @params        = params
    end

    def call
      invitation = InvitationRepository.new.find_by_id_or_slug(@invitation_id)
      repo       = InvitationDocumentRepository.new
      document   = repo.find_by_invitation(invitation)
      document   = repo.update_document(document, meta: @params[:meta], document_body: @params[:document])
      ServiceResult.success({ document: document })
    end
  end
end
