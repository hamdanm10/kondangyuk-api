json.status "success"
json.data do
  json.orders @orders do |order|
    json.id           order.id
    json.order_number order.order_number
    json.status       order.status
    json.template do
      json.id   order.template.id
      json.slug order.template.slug
      json.name order.template.name
    end
    json.marketplace do
      json.id   order.marketplace.id
      json.name order.marketplace.name
    end
    json.invitation do
      json.id           order.invitation.id
      json.slug         order.invitation.slug
      json.name         order.invitation.name
      json.published_at order.invitation.published_at
      json.expires_at   order.invitation.expires_at
    end
    json.created_at order.created_at
  end
  json.pagination do
    json.current_page @pagy.page
    json.total_pages  @pagy.pages
    json.total_count  @pagy.count
    json.prev_page    @pagy.previous
    json.next_page    @pagy.next
    json.limit        @pagy.limit
  end
end
