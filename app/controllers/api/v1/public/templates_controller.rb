module Api
  module V1
    module Public
      class TemplatesController < Api::V1::GuestApplicationController
        def index
          result = Templates::ListService.call(
            theme_id: params[:theme_id], tier_id: params[:tier_id], published_only: true
          )
          @pagy, @templates = pagy(:offset, result.data[:collection])
          render_success(nil, :ok)
        end
      end
    end
  end
end
