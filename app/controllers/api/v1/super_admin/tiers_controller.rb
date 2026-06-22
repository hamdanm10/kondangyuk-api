module Api
  module V1
    class SuperAdmin::TiersController < Api::V1::SuperAdmin::BaseController
      def index
        result = Tiers::ListService.call
        @pagy, @tiers = paginate(result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Tiers::ShowService.call(id: params[:id])
        @tier = result.data[:tier]
        render_success(nil, :ok)
      end

      def create
        result = Tiers::CreateService.call(params: tier_params)
        if result.success?
          @tier = result.data[:tier]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Tiers::UpdateService.call(id: params[:id], params: tier_params)
        if result.success?
          @tier = result.data[:tier]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Tiers::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def tier_params
        params.require(:tier).permit(:name, :price)
      end
    end
  end
end
