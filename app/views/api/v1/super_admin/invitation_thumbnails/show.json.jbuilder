json.status "success"
json.data do
  json.thumbnail do
    json.url @record.thumbnail.attached? ? rails_storage_proxy_url(@record.thumbnail) : nil
  end
end
