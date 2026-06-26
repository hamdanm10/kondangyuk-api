module Api
  module V1
    class SuperAdmin::InvitationsController < Api::V1::SuperAdmin::BaseController
      # Invitations are created/updated/deleted through their order (Order has_one Invitation);
      # only the read-only detail is exposed here.
      def show
        result = Invitations::ShowService.call(id: params[:id])
        @invitation = result.data[:invitation]
        render_success(nil, :ok)
      end
    end
  end
end
