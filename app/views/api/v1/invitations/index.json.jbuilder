json.status "success"
json.data do
  json.invitations @invitations do |invitation|
    json.id           invitation.id
    json.slug         invitation.slug
    json.name         invitation.name
    json.description  invitation.description
    json.published_at invitation.published_at
    json.expires_at   invitation.expires_at
    json.order do
      json.id     invitation.order.id
      json.status invitation.order.status
    end
    json.thumbnail_url invitation.thumbnail.attached? ? rails_storage_proxy_url(invitation.thumbnail) : nil
    json.created_at invitation.created_at
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
