json.status "success"
json.data do
  json.template do
    json.id           @template.id
    json.slug         @template.slug
    json.name         @template.name
    json.description  @template.description
    json.published_at @template.published_at
    json.created_at   @template.created_at
    json.updated_at   @template.updated_at
  end
end
