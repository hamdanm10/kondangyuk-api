json.status "success"
json.data do
  json.themes @themes do |theme|
    json.id   theme.id
    json.name theme.name
  end
end
