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
    json.created_at @invitation.created_at
  end
end
