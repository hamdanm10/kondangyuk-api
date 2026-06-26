module Api
  module V1
    class SuperAdmin::InvitationPublicationsController < Api::V1::SuperAdmin::BaseController
      def create
        result      = Invitations::PublishService.call(id: params[:invitation_id])
        @invitation = result.data[:invitation]
        render_success(nil, :ok)
      end

      def destroy
        result      = Invitations::UnpublishService.call(id: params[:invitation_id])
        @invitation = result.data[:invitation]
        render_success(nil, :ok)
      end
    end
  end
end
