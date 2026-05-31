class ThemeRepository < BaseRepository
  def list_all
    Theme.order(:name)
  end

  def create_theme(name:)
    Theme.create!(name: name)
  end

  def find_by_id(id)
    Theme.find(id)
  end

  def destroy_theme(theme)
    theme.destroy!
  end

  private

  def model
    Theme
  end
end
