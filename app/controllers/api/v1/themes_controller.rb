module Api
  module V1
    class ThemesController < SuperAdminApplicationController
      def index
        result = Themes::ListService.call
        @pagy, @themes = pagy(:offset, result.data[:collection])
        render_success(nil, :ok)
      end
    end
  end
end
