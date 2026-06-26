module Orders
  class UpdateService < BaseService
    def initialize(id:, order:, invitation:)
      @id         = id
      @order      = order
      @invitation = invitation
    end

    def call
      repo  = OrderRepository.new
      order = repo.find_by_id(@id)

      invalid = invalid_status
      return invalid if invalid

      order = repo.update_order(order, order_attributes)
      ServiceResult.success({ order: order, invitation: order.invitation })
    end

    private

    # PATCH semantics: only the fields actually sent are written, so a partial form never clobbers
    # the others. Invitation fields ride along as nested attributes on the order.
    def order_attributes
      attrs = {}
      attrs[:template_id]    = @order[:template_id]    if @order[:template_id].present?
      attrs[:marketplace_id] = @order[:marketplace_id] if @order[:marketplace_id].present?
      attrs[:order_number]   = @order[:order_number]   if @order[:order_number].present?
      attrs[:status]         = @order[:status]         if @order[:status].present?

      nested = invitation_attributes
      attrs[:invitation_attributes] = nested if nested.present?
      attrs
    end

    def invitation_attributes
      %i[name slug description].each_with_object({}) do |key, h|
        h[key] = @invitation[key] if @invitation[key].present?
      end
    end

    def invalid_status
      return nil if @order[:status].blank? || Order.statuses.key?(@order[:status])

      ServiceResult.failure(status: [ I18n.t("messages.errors.invalid_order_status") ])
    end
  end
end
