module Orders
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo  = OrderRepository.new
      order = repo.find_by_id(@id)

      invalid = invalid_status
      return invalid if invalid

      order = repo.update_order(
        order,
        template_id: @params[:template_id],
        price:       @params[:price],
        status:      @params[:status]
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
