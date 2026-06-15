json.status "success"
json.data do
  json.template do
    json.id           @template.id
    json.slug         @template.slug
    json.name         @template.name
    json.description  @template.description
    json.published_at @template.published_at
    json.created_at   @template.created_at
    json.themes @template.themes do |theme|
      json.id   theme.id
      json.name theme.name
    end
    if @template.tier
      json.tier do
        json.id   @template.tier.id
        json.name @template.tier.name
      end
    else
      json.tier nil
    end
  end
end
