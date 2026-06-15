module Invitations
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      invitation = InvitationRepository.new.find_by_id_or_slug(@id)
      ServiceResult.success({ invitation: invitation })
    end
  end
end
