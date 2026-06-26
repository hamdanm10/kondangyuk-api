module Api
  module V1
    class SuperAdmin::OrderStatusesController < Api::V1::SuperAdmin::BaseController
      def update
        result = Orders::UpdateStatusService.call(id: params[:order_id], status: status_param)
        if result.success?
          @order = result.data[:order]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      private

      def status_param
        params.require(:order).permit(:status)[:status]
      end
    end
  end
end
