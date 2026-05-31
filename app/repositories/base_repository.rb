class BaseRepository
  private

  def model
    raise NotImplementedError, "#{self.class} must implement #model"
  end
end
