json.status "success"
json.data do
  json.marketplaces @marketplaces do |marketplace|
    json.id         marketplace.id
    json.name       marketplace.name
    json.created_at marketplace.created_at
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
