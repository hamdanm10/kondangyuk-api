class InvitationRepository < BaseRepository
  def find_by_id_or_slug(value)
    scope = Invitation.active.includes(:order)
    if value.to_s.match?(/\A\d+\z/)
      scope.find(value)
    else
      scope.find_by!(slug: value)
    end
  end

  def find_published_by_slug(slug)
    Invitation.published.find_by!(slug: slug)
  end

  def set_published(invitation, published_at:)
    invitation.update!(published_at: published_at)
    invitation
  end

  private

  def model
    Invitation
  end
end
