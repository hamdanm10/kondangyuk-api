json.status "success"
json.data do
  json.templates @templates do |template|
    json.id   template.id
    json.name template.name
    json.slug template.slug
  end
end
