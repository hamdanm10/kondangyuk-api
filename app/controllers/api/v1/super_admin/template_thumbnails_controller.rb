module Api
  module V1
    class SuperAdmin::TemplateThumbnailsController < Api::V1::SuperAdmin::BaseController
      def show
        @record = template
        render_success(nil, :ok)
      end

      def update
        result = Thumbnails::AttachService.call(record: template, file: thumbnail_file)
        if result.success?
          @record = result.data[:record]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Thumbnails::DetachService.call(record: template)
        render_success({}, :ok)
      end

      private

      def template
        @template ||= Templates::ShowService.call(id: params[:template_id]).data[:template]
      end

      def thumbnail_file
        params.permit(:thumbnail)[:thumbnail]
      end
    end
  end
end
