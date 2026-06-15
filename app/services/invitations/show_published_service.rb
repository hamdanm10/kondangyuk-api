module Invitations
  class ShowPublishedService < BaseService
    def initialize(slug:)
      @slug = slug
    end

    def call
      invitation = InvitationRepository.new.find_published_by_slug(@slug)
      document   = InvitationDocumentRepository.new.find_by_invitation(invitation)
      ServiceResult.success({ invitation: invitation, document: document })
    end
  end
end
