class OrderRepository < BaseRepository
  def list_all
    Order.includes(:template).order(created_at: :desc)
  end

  def find_by_id(id)
    Order.includes(:template).find(id)
  end

  def create_order(template_id:, price:, status:)
    attrs = { template_id: template_id, price: price }
    attrs[:status] = status if status.present?
    Order.create!(attrs)
  end

  def update_order(order, template_id:, price:, status:)
    attrs = {}
    attrs[:template_id] = template_id if template_id.present?
    attrs[:price] = price if price.present?
    attrs[:status] = status if status.present?
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
