json.status "success"
json.data do
  json.themes @themes do |theme|
    json.id         theme.id
    json.name       theme.name
    json.created_at theme.created_at
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
