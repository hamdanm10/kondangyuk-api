class OrderRepository < BaseRepository
  def list_all
    Order.includes(:template, :marketplace).order(created_at: :desc)
  end

  def find_by_id(id)
    Order.includes(:template, :marketplace).find(id)
  end

  def create_order(template_id:, marketplace_id:, order_number:, status:)
    attrs = { template_id: template_id, marketplace_id: marketplace_id, order_number: order_number }
    attrs[:status] = status if status.present?
    Order.create!(attrs)
  end

  def update_order(order, template_id:, marketplace_id:, order_number:, status:)
    attrs = {}
    attrs[:template_id]    = template_id    if template_id.present?
    attrs[:marketplace_id] = marketplace_id if marketplace_id.present?
    attrs[:order_number]   = order_number   if order_number.present?
    attrs[:status]         = status         if status.present?
    order.update!(attrs)
    order
  end

  def delete_order(order)
    order.destroy!
  end

  private

  def model
    Order
  end
end
