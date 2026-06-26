json.status "success"
json.data do
  json.order do
    json.id           @order.id
    json.order_number @order.order_number
    json.status       @order.status
    json.updated_at   @order.updated_at
  end
end
