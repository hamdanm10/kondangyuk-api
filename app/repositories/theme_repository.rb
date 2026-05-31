class ThemeRepository < BaseRepository
  def list_all
    Theme.order(:name)
  end

  def create_theme(name:)
    Theme.create!(name: name)
  end

  private

  def model
    Theme
  end
end
