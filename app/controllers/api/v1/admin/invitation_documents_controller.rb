module Api
  module V1
    class Admin::InvitationDocumentsController < Api::V1::Admin::BaseController
      def show
        result = InvitationDocuments::ShowService.call(invitation_id: params[:invitation_id])
        @document = result.data[:document]
        render_success(nil, :ok)
      end

      def update
        result = InvitationDocuments::UpdateService.call(
          invitation_id: params[:invitation_id],
          params:        invitation_document_params
        )
        if result.success?
          @document = result.data[:document]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        InvitationDocuments::DestroyService.call(invitation_id: params[:invitation_id])
        render_success({}, :ok)
      end

      private

      def invitation_document_params
        params.require(:invitation_document).permit(:document, meta: {})
      end
    end
  end
end
