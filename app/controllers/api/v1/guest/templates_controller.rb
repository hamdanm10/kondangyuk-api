module Api
  module V1
    module Guest
      class TemplatesController < Api::V1::Guest::BaseController
        def index
          result = Templates::ListService.call(query: search_params, published_only: true)
          @pagy, @templates = paginate(result.data[:collection])
          render_success(nil, :ok)
        end

        def show
          result = Templates::ShowPublishedService.call(slug: params[:slug])
          @template = result.data[:template]
          @document = result.data[:document]
          render_success(nil, :ok)
        end

        private

        def search_params
          params.fetch(:q, {}).permit(:name_or_slug_cont, :themes_id_eq, :tier_id_eq)
        end
      end
    end
  end
end
