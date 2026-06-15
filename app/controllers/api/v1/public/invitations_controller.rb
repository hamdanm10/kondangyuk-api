module Api
  module V1
    module Public
      class InvitationsController < Api::V1::GuestApplicationController
        def show
          result = Invitations::ShowPublishedService.call(slug: params[:slug])
          @invitation = result.data[:invitation]
          @document   = result.data[:document]
          render_success(nil, :ok)
        end
      end
    end
  end
end
