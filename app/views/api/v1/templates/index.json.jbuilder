json.status "success"
json.data do
  json.templates @templates do |template|
    json.id           template.id
    json.slug         template.slug
    json.name         template.name
    json.description  template.description
    json.published_at template.published_at
    json.created_at   template.created_at
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
