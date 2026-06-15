json.status "success"
json.data do
  json.templates @templates do |template|
    json.id           template.id
    json.slug         template.slug
    json.name         template.name
    json.description  template.description
    json.published_at template.published_at
    json.created_at   template.created_at
    json.thumbnail_url template.thumbnail.attached? ? rails_storage_proxy_url(template.thumbnail) : nil
    json.themes template.themes do |theme|
      json.id   theme.id
      json.name theme.name
    end
    if template.tier
      json.tier do
        json.id   template.tier.id
        json.name template.tier.name
      end
    else
      json.tier nil
    end
  end
  json.pagination do
    json.current_page @pagy.page
    json.total_pages  @pagy.pages
    json.total_count  @pagy.count
    json.prev_page    @pagy.previous
    json.next_page    @pagy.next
    json.limit        @pagy.limit
  end
end
