class MediaRepository < BaseRepository
  def list(record)
    attachments_for(record).includes(:blob).order(:id)
  end

  def attach(record, file)
    record.media.attach(file)
    attachments_for(record).order(:id).last
  end

  def find(record, id)
    attachments_for(record).find(id)
  end

  def purge(attachment)
    attachment.purge
  end

  private

  def attachments_for(record)
    ActiveStorage::Attachment.where(record: record, name: "media")
  end

  def model
    ActiveStorage::Attachment
  end
end
