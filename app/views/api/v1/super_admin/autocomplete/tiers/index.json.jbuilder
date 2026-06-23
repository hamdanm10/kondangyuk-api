json.status "success"
json.data do
  json.tiers @tiers do |tier|
    json.id   tier.id
    json.name tier.name
  end
end
