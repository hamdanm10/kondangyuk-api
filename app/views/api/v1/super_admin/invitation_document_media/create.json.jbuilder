json.status "success"
json.data do
  json.media do
    json.id           @media_item.id
    json.url          rails_storage_proxy_url(@media_item)
    json.filename     @media_item.blob.filename.to_s
    json.content_type @media_item.blob.content_type
    json.byte_size    @media_item.blob.byte_size
    json.created_at   @media_item.created_at
  end
end
