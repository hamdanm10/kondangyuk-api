json.status "success"
json.data do
  json.users @users do |user|
    json.id         user.id
    json.full_name  user.full_name
    json.email      user.email
    json.role       user.role
    json.is_active  user.is_active
    json.created_at user.created_at
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
