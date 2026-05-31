class UserRepository < BaseRepository
  def find_by_email(email)
    User.find_by(email: email)
  end

  def find_by_id(id)
    User.find_by(id: id)
  end

  def find_admins
    User.where(role: :admin)
  end

  def find_super_admins
    User.where(role: :super_admin)
  end

  def find_by_role(role)
    User.where(role: role)
  end

  def list_all
    User.order(:created_at)
  end

  def create_user(email:, password:, role:)
    User.create!(email: email, password: password, role: role)
  end

  private

  def model
    User
  end
end
