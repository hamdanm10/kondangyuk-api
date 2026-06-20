module Api
  module V1
    class SuperAdmin::InvitationThumbnailsController < Api::V1::SuperAdmin::BaseController
      def show
        @record = invitation
        render_success(nil, :ok)
      end

      def update
        result = Thumbnails::AttachService.call(record: invitation, file: thumbnail_file)
        if result.success?
          @record = result.data[:record]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Thumbnails::DetachService.call(record: invitation)
        render_success({}, :ok)
      end

      private

      def invitation
        @invitation ||= Invitations::ShowService.call(id: params[:invitation_id]).data[:invitation]
      end

      def thumbnail_file
        params.permit(:thumbnail)[:thumbnail]
      end
    end
  end
end
