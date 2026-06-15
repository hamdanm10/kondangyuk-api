class ThumbnailRepository < BaseRepository
  def attach(record, file)
    record.thumbnail.attach(file)
    record.thumbnail
  end

  def purge(record)
    record.thumbnail.purge if record.thumbnail.attached?
  end

  private

  def model
    ActiveStorage::Attachment
  end
end
