class UserRepository < BaseRepository
  def find_by_email(email)
    User.find_by(email: email)
  end

  def find_by_id(id)
    User.find_by(id: id)
  end

  def find_by_id!(id)
    User.find(id)
  end

  def set_active(user, active:)
    user.update!(is_active: active)
    user
  end

  def list_non_super_admins(query = {})
    User.where.not(role: :super_admin).ransack(query).result.order(:created_at)
  end

  def create_user(email:, password:, role:, full_name:)
    User.create!(email: email, password: password, role: role, full_name: full_name)
  end

  private

  def model
    User
  end
end
