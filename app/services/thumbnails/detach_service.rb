module Thumbnails
  class DetachService < BaseService
    def initialize(record:)
      @record = record
    end

    def call
      ThumbnailRepository.new.purge(@record)
      ServiceResult.success({})
    end
  end
end
