module Api
  module V1
    class SuperAdmin::OrdersController < Api::V1::SuperAdmin::BaseController
      def index
        result = Orders::ListService.call
        @pagy, @orders = pagy(:offset, result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Orders::ShowService.call(id: params[:id])
        @order = result.data[:order]
        render_success(nil, :ok)
      end

      def create
        result = Orders::CreateService.call(params: order_params)
        if result.success?
          @order = result.data[:order]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Orders::UpdateService.call(id: params[:id], params: order_params)
        if result.success?
          @order = result.data[:order]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Orders::DestroyService.call(id: params[:id])
        render_success({}, :ok)
      end

      private

      def order_params
        params.require(:order).permit(:template_id, :price, :status)
      end
    end
  end
end
