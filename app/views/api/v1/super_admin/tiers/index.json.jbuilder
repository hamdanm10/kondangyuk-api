json.status "success"
json.data do
  json.tiers @tiers do |tier|
    json.id         tier.id
    json.name       tier.name
    json.price      tier.price.to_s
    json.created_at tier.created_at
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
