json.status "success"
json.data do
  json.theme do
    json.id         @theme.id
    json.name       @theme.name
    json.created_at @theme.created_at
    json.updated_at @theme.updated_at
  end
end
