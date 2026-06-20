json.status "success"
json.data do
  json.media @media do |item|
    json.id           item.id
    json.url          rails_storage_proxy_url(item)
    json.filename     item.blob.filename.to_s
    json.content_type item.blob.content_type
    json.byte_size    item.blob.byte_size
    json.created_at   item.created_at
  end
end
