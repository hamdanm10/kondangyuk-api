module Api
  module V1
    class SuperAdmin::InvitationsController < Api::V1::SuperAdmin::BaseController
      def index
        result = Invitations::ListService.call
        @pagy, @invitations = pagy(:offset, result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Invitations::ShowService.call(id: params[:id])
        @invitation = result.data[:invitation]
        render_success(nil, :ok)
      end

      def create
        result = Invitations::CreateService.call(params: invitation_params)
        if result.success?
          @invitation = result.data[:invitation]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Invitations::UpdateService.call(id: params[:id], params: invitation_params)
        if result.success?
          @invitation = result.data[:invitation]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Invitations::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def invitation_params
        params.require(:invitation).permit(
          :order_id, :slug, :name, :description, :published_at, :expires_at
        )
      end
    end
  end
end
