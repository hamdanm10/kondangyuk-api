json.status "success"
json.data do
  json.user do
    json.id         @user.id
    json.full_name  @user.full_name
    json.email      @user.email
    json.role       @user.role
    json.is_active  @user.is_active
    json.created_at @user.created_at
  end
end
