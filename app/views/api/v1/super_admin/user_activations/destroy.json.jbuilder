json.status "success"
json.data do
  json.user do
    json.id        @user.id
    json.full_name @user.full_name
    json.email     @user.email
    json.role      @user.role
    json.is_active @user.is_active
  end
end
