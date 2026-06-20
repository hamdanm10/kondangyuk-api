json.status "success"
json.data do
  json.tier do
    json.id         @tier.id
    json.name       @tier.name
    json.price      @tier.price.to_s
    json.created_at @tier.created_at
  end
end
