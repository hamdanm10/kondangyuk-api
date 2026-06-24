module Orders
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      invalid = invalid_status
      return invalid if invalid

      order = OrderRepository.new.create_order(
        template_id:    @params[:template_id],
        marketplace_id: @params[:marketplace_id],
        order_number:   @params[:order_number],
        status:         @params[:status]
      )
      ServiceResult.success({ order: order })
    end

    private

    def invalid_status
      return nil if @params[:status].blank? || Order.statuses.key?(@params[:status])

      ServiceResult.failure(status: [ I18n.t("messages.errors.invalid_order_status") ])
    end
  end
end
