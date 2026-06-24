json.status "success"
json.data do
  json.marketplace do
    json.id         @marketplace.id
    json.name       @marketplace.name
    json.created_at @marketplace.created_at
    json.updated_at @marketplace.updated_at
  end
end
