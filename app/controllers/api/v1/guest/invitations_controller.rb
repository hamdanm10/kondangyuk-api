module Api
  module V1
    module Guest
      class InvitationsController < Api::V1::Guest::BaseController
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
