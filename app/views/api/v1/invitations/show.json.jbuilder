json.status "success"
json.data do
  json.invitation do
    json.id           @invitation.id
    json.slug         @invitation.slug
    json.name         @invitation.name
    json.description  @invitation.description
    json.published_at @invitation.published_at
    json.expires_at   @invitation.expires_at
    json.order do
      json.id     @invitation.order.id
      json.status @invitation.order.status
    end
    json.thumbnail_url @invitation.thumbnail.attached? ? rails_storage_proxy_url(@invitation.thumbnail) : nil
    json.created_at @invitation.created_at
    json.updated_at @invitation.updated_at
  end
end
