module Orders
  class UpdateStatusService < BaseService
    def initialize(id:, status:)
      @id     = id
      @status = status
    end

    def call
      repo  = OrderRepository.new
      order = repo.find_by_id(@id)

      return invalid_status unless Order.statuses.key?(@status)

      order = repo.update_order(order, status: @status)
      ServiceResult.success({ order: order })
    end

    private

    def invalid_status
      ServiceResult.failure(status: [ I18n.t("messages.errors.invalid_order_status") ])
    end
  end
end
