class TemplateRepository < BaseRepository
  def list_all
    Template.active.includes(:created_by_user).order(:name)
  end

  def find_by_id_or_slug(value)
    if value.to_s.match?(/\A\d+\z/)
      Template.active.find(value)
    else
      Template.active.find_by!(slug: value)
    end
  end

  def create_with_document(slug:, name:, description:, published_at:, created_by_user:, meta:, document:)
    Template.transaction do
      template = Template.create!(
        slug: slug,
        name: name,
        description: description,
        published_at: published_at,
        created_by_user: created_by_user
      )
      template.create_template_document!(meta: meta || {}, document: document)
      template
    end
  end

  def update_template(template, slug:, name:, description:, published_at:)
    template.update!(slug: slug, name: name, description: description, published_at: published_at)
    template
  end

  def soft_delete(template)
    template.update!(deleted_at: Time.current)
  end

  private

  def model
    Template
  end
end
