json.status "success"
json.data do
  json.marketplaces @marketplaces do |marketplace|
    json.id   marketplace.id
    json.name marketplace.name
  end
end
