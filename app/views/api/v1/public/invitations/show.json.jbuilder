json.status "success"
json.data do
  json.invitation do
    json.id           @invitation.id
    json.slug         @invitation.slug
    json.name         @invitation.name
    json.description  @invitation.description
    json.published_at @invitation.published_at
    json.expires_at   @invitation.expires_at
    json.thumbnail_url @invitation.thumbnail.attached? ? rails_storage_proxy_url(@invitation.thumbnail) : nil
    json.document do
      json.meta     @document.meta
      json.document @document.document
    end
  end
end
