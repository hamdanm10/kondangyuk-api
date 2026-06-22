module Api
  module V1
    class SuperAdmin::TemplatesController < Api::V1::SuperAdmin::BaseController
      def index
        result = Templates::ListService.call(query: search_params)
        @pagy, @templates = paginate(result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Templates::ShowService.call(id: params[:id])
        @template = result.data[:template]
        render_success(nil, :ok)
      end

      def create
        result = Templates::CreateService.call(params: template_params, created_by_user: current_user)
        if result.success?
          @template = result.data[:template]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Templates::UpdateService.call(id: params[:id], params: template_params)
        if result.success?
          @template = result.data[:template]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Templates::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def template_params
        params.require(:template).permit(
          :slug, :name, :description, :published_at, :document, :tier_id, meta: {}, theme_ids: []
        )
      end

      def search_params
        params.fetch(:q, {}).permit(:name_or_slug_cont, :themes_id_eq, :tier_id_eq)
      end
    end
  end
end
