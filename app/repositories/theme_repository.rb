class ThemeRepository < BaseRepository
  def list_all
    Theme.order(:name)
  end

  private

  def model
    Theme
  end
end
