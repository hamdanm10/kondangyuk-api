json.status "success"
json.data do
  json.order do
    json.id           @order.id
    json.order_number @order.order_number
    json.status       @order.status
    json.template do
      json.id   @order.template.id
      json.slug @order.template.slug
      json.name @order.template.name
    end
    json.marketplace do
      json.id   @order.marketplace.id
      json.name @order.marketplace.name
    end
    json.created_at @order.created_at
    json.updated_at @order.updated_at
  end
end
