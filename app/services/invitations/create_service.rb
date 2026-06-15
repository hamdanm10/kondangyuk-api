module Invitations
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      order = OrderRepository.new.find_by_id(@params[:order_id])

      invitation = InvitationRepository.new.create_from_order(
        order:        order,
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
