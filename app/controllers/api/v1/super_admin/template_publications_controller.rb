module Api
  module V1
    class SuperAdmin::TemplatePublicationsController < Api::V1::SuperAdmin::BaseController
      def create
        result    = Templates::PublishService.call(id: params[:template_id])
        @template = result.data[:template]
        render_success(nil, :ok)
      end

      def destroy
        result    = Templates::UnpublishService.call(id: params[:template_id])
        @template = result.data[:template]
        render_success(nil, :ok)
      end
    end
  end
end
