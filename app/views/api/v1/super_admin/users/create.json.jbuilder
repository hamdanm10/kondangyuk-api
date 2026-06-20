json.status "success"
json.data do
  json.user do
    json.id         @user.id
    json.email      @user.email
    json.role       @user.role
    json.created_at @user.created_at
  end
end
