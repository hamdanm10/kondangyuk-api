module Api
  module V1
    class SuperAdmin::OrdersController < Api::V1::SuperAdmin::BaseController
      def index
        result = Orders::ListService.call(query: search_params)
        @pagy, @orders = paginate(result.data[:collection])
        render_success(nil, :ok)
      end

      def show
        result = Orders::ShowService.call(id: params[:id])
        @order      = result.data[:order]
        @invitation = @order.invitation
        render_success(nil, :ok)
      end

      def create
        result = Orders::CreateService.call(order: order_params, invitation: invitation_params)
        if result.success?
          @order      = result.data[:order]
          @invitation = result.data[:invitation]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def update
        result = Orders::UpdateService.call(id: params[:id], order: order_params, invitation: invitation_params)
        if result.success?
          @order      = result.data[:order]
          @invitation = result.data[:invitation]
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
        params.require(:order).permit(:template_id, :marketplace_id, :order_number)
      end

      def invitation_params
        params.require(:invitation).permit(:name, :slug, :description)
      end

      def search_params
        params.fetch(:q, {}).permit(
          :order_number_cont, :invitation_name_cont, :invitation_slug_cont,
          :status_eq, :marketplace_id_eq, :template_id_eq,
          :created_at_gteq, :created_at_lteq
        )
      end
    end
  end
end
