module Orders
  class CreateService < BaseService
    # An invitation stays live for six months from the moment the order is created.
    INVITATION_TTL = 6.months

    def initialize(order:, invitation:)
      @order      = order
      @invitation = invitation
    end

    def call
      # Status is not set here — it defaults to "pending" and is changed via the status endpoint.
      order = OrderRepository.new.create_order(order_attributes)
      ServiceResult.success({ order: order, invitation: order.invitation })
    end

    private

    def order_attributes
      {
        template_id:    @order[:template_id],
        marketplace_id: @order[:marketplace_id],
        order_number:   @order[:order_number],
        # published_at starts empty; expires_at is fixed at six months from creation.
        invitation_attributes: {
          name:         @invitation[:name],
          slug:         @invitation[:slug],
          description:  @invitation[:description],
          published_at: nil,
          expires_at:   INVITATION_TTL.from_now
        }
      }
    end
  end
end
