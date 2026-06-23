class ThemeRepository < BaseRepository
  def list_all(query = {})
    Theme.active.ransack(query).result.order(:name)
  end

  def autocomplete(query = {})
    Theme.active.ransack(query).result.order(:name).limit(10).select(:id, :name)
  end

  def create_theme(name:)
    Theme.create!(name: name)
  end

  def find_by_id(id)
    Theme.active.find(id)
  end

  def active_by_ids(ids)
    Theme.active.where(id: ids)
  end

  def update_theme(theme, name:)
    theme.update!(name: name)
    theme
  end

  def soft_delete(theme)
    theme.update!(deleted_at: Time.current)
  end

  private

  def model
    Theme
  end
end
