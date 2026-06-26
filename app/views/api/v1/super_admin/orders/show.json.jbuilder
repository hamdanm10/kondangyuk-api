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
  json.invitation do
    json.id           @invitation.id
    json.slug         @invitation.slug
    json.name         @invitation.name
    json.description  @invitation.description
    json.published_at @invitation.published_at
    json.expires_at   @invitation.expires_at
    json.created_at   @invitation.created_at
    json.updated_at   @invitation.updated_at
  end
end
