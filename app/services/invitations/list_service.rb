module Invitations
  class ListService < BaseService
    def call
      collection = InvitationRepository.new.list_all
      ServiceResult.success({ collection: collection })
    end
  end
end
