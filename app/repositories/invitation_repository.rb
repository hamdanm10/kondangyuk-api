class InvitationRepository < BaseRepository
  def list_all
    Invitation.includes(:order, thumbnail_attachment: :blob).order(created_at: :desc)
  end

  def find_by_id_or_slug(value)
    scope = Invitation.includes(:order)
    if value.to_s.match?(/\A\d+\z/)
      scope.find(value)
    else
      scope.find_by!(slug: value)
    end
  end

  def find_published_by_slug(slug)
    Invitation.published.find_by!(slug: slug)
  end

  def create_from_order(order:, slug:, name:, description:, published_at:, expires_at:)
    template = order.template
    snapshot = template.template_document
    raise ActiveRecord::RecordNotFound, "Template has no document to snapshot" if snapshot.nil?

    Invitation.transaction do
      invitation = Invitation.create!(
        order:        order,
        slug:         slug,
        name:         name.presence || template.name,
        description:  description.presence || template.description,
        published_at: published_at,
        expires_at:   expires_at
      )
      invitation.create_invitation_document!(meta: snapshot.meta, document: snapshot.document)
      invitation
    end
  end

  def update_invitation(invitation, slug:, name:, description:, published_at:, expires_at:)
    invitation.update!(
      slug: slug, name: name, description: description,
      published_at: published_at, expires_at: expires_at
    )
    invitation
  end

  def delete_invitation(invitation)
    invitation.destroy!
  end

  private

  def model
    Invitation
  end
end
