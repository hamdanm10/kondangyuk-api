class SessionRepository < BaseRepository
  def find_by_token(token)
    Session.find_by(token: token)
  end

  def create_session(user:, ip_address: nil, user_agent: nil)
    Session.create!(user: user, ip_address: ip_address, user_agent: user_agent)
  end

  def destroy_session(session)
    session.destroy
  end

  def find_active_by_user(user_id)
    Session.where(user_id: user_id)
  end

  private

  def model
    Session
  end
end
