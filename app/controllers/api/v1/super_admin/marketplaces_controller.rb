module Api
  module V1
    class SuperAdmin::MarketplacesController < Api::V1::SuperAdmin::BaseController
      def index
        result = Marketplaces::ListService.call(query: search_params)
        @pagy, @marketplaces = paginate(result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Marketplaces::ShowService.call(id: params[:id])
        @marketplace = result.data[:marketplace]
        render_success(nil, :ok)
      end

      def create
        result = Marketplaces::CreateService.call(params: marketplace_params)
        if result.success?
          @marketplace = result.data[:marketplace]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Marketplaces::UpdateService.call(id: params[:id], params: marketplace_params)
        if result.success?
          @marketplace = result.data[:marketplace]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Marketplaces::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def marketplace_params
        params.require(:marketplace).permit(:name)
      end

      def search_params
        params.fetch(:q, {}).permit(:name_cont)
      end
    end
  end
end
