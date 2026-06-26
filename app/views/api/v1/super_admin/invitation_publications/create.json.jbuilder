json.status "success"
json.data do
  json.invitation do
    json.id           @invitation.id
    json.slug         @invitation.slug
    json.name         @invitation.name
    json.published_at @invitation.published_at
    json.expires_at   @invitation.expires_at
  end
end
