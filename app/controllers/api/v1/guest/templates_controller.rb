module Api
  module V1
    module Guest
      class TemplatesController < Api::V1::Guest::BaseController
        def index
          result = Templates::ListService.call(
            theme_id: params[:theme_id], tier_id: params[:tier_id], published_only: true
          )
          @pagy, @templates = pagy(:offset, result.data[:collection])
          render_success(nil, :ok)
        end

        def show
          result = Templates::ShowPublishedService.call(slug: params[:slug])
          @template = result.data[:template]
          @document = result.data[:document]
          render_success(nil, :ok)
        end
      end
    end
  end
end
