class TemplateRepository < BaseRepository
  def list_all(query: {}, published_only: false)
    scope = Template.active
    scope = scope.published if published_only
    scope.ransack(query).result
         .order(:name)
         .includes(:created_by_user, :themes, :tier)
  end

  def find_by_id_or_slug(value)
    scope = Template.active.includes(:themes, :tier)
    if value.to_s.match?(/\A\d+\z/)
      scope.find(value)
    else
      scope.find_by!(slug: value)
    end
  end

  def find_published_by_slug(slug)
    Template.active.published
            .includes(:themes, :tier, thumbnail_attachment: :blob)
            .find_by!(slug: slug)
  end

  def create_with_document(slug:, name:, description:, published_at:, created_by_user:, meta:, document:, themes: [], tier: nil)
    Template.transaction do
      template = Template.create!(
        slug: slug,
        name: name,
        description: description,
        published_at: published_at,
        created_by_user: created_by_user
      )
      template.create_template_document!(meta: meta || {}, document: document)
      template.themes = themes
      template.tier   = tier
      template
    end
  end

  # Scalar columns use PATCH semantics: only keys present in `attrs` are written, so a
  # partial payload (e.g. the publish toggle, or the config form omitting published_at)
  # never clobbers fields it didn't send. Themes/tier follow the same rule via sync_*.
  def update_template(template, attrs:, themes: [], tier: nil, sync_themes: false, sync_tier: false)
    Template.transaction do
      template.update!(attrs)
      template.themes = themes if sync_themes
      template.tier   = tier   if sync_tier
      template
    end
  end

  def soft_delete(template)
    template.update!(deleted_at: Time.current)
  end

  private

  def model
    Template
  end
end
