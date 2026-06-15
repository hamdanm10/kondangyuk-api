module Invitations
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo       = InvitationRepository.new
      invitation = repo.find_by_id_or_slug(@id)
      invitation = repo.update_invitation(
        invitation,
        slug:         @params[:slug],
        name:         @params[:name],
        description:  @params[:description],
        published_at: @params[:published_at],
        expires_at:   @params[:expires_at]
      )
      ServiceResult.success({ invitation: invitation })
    end
  end
end
