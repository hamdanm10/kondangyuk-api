class SessionRepository < BaseRepository
  SESSION_TTL = 30.days

  def find_by_token(token)
    Session.where(token: token).where("expires_at > ?", Time.current).first
  end

  def create_session(user:, ip_address: nil, user_agent: nil)
    Session.create!(
      user: user,
      ip_address: ip_address,
      user_agent: user_agent,
      expires_at: SESSION_TTL.from_now
    )
  end

  def destroy_session(session)
    session.destroy
  end

  def destroy_all_for_user(user_id)
    Session.where(user_id: user_id).delete_all
  end

  def delete_expired
    Session.where("expires_at <= ?", Time.current).delete_all
  end

  def find_active_by_user(user_id)
    Session.where(user_id: user_id).where("expires_at > ?", Time.current)
  end

  private

  def model
    Session
  end
end
