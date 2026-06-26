json.status "success"
json.data do
  json.template do
    json.id           @template.id
    json.slug         @template.slug
    json.name         @template.name
    json.published_at @template.published_at
  end
end
