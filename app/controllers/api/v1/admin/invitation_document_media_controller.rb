module Api
  module V1
    class Admin::InvitationDocumentMediaController < Api::V1::Admin::BaseController
      def index
        @media = Media::ListService.call(record: document).data[:media]
        render_success(nil, :ok)
      end

      def create
        result = Media::AttachService.call(record: document, file: media_file)
        if result.success?
          @media_item = result.data[:media]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Media::DetachService.call(record: document, media_id: params[:id])
        render_success({}, :ok)
      end

      private

      def document
        @document ||= InvitationDocuments::ShowService.call(invitation_id: params[:invitation_id]).data[:document]
      end

      def media_file
        params.permit(:file)[:file]
      end
    end
  end
end
