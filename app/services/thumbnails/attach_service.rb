module Thumbnails
  class AttachService < BaseService
    def initialize(record:, file:)
      @record = record
      @file   = file
    end

    def call
      return ServiceResult.failure(thumbnail: [ "is required" ]) if @file.blank?

      kind = @file.content_type.to_s.split("/").first
      return ServiceResult.failure(thumbnail: [ "must be an image" ]) unless kind == "image"

      ThumbnailRepository.new.attach(@record, @file)
      ServiceResult.success({ record: @record })
    end
  end
end
