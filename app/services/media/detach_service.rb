module Media
  class DetachService < BaseService
    def initialize(record:, media_id:)
      @record   = record
      @media_id = media_id
    end

    def call
      repo       = MediaRepository.new
      attachment = repo.find(@record, @media_id)
      repo.purge(attachment)
      ServiceResult.success({})
    end
  end
end
