module Api
  module V1
    class ThemesController < SuperAdminApplicationController
      def index
        result = Themes::ListService.call
        @pagy, @themes = pagy(:offset, result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Themes::ShowService.call(id: params[:id])
        @theme = result.data[:theme]
        render_success(nil, :ok)
      end

      def create
        result = Themes::CreateService.call(params: theme_params)
        if result.success?
          @theme = result.data[:theme]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Themes::UpdateService.call(id: params[:id], params: theme_params)
        if result.success?
          @theme = result.data[:theme]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Themes::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def theme_params
        params.require(:theme).permit(:name)
      end
    end
  end
end
