module Media
  class AttachService < BaseService
    ALLOWED_TYPES = %w[image audio video].freeze

    def initialize(record:, file:)
      @record = record
      @file   = file
    end

    def call
      return ServiceResult.failure(file: [ I18n.t("messages.errors.file_required") ]) if @file.blank?

      kind = @file.content_type.to_s.split("/").first
      unless ALLOWED_TYPES.include?(kind)
        return ServiceResult.failure(file: [ I18n.t("messages.errors.file_invalid_type") ])
      end

      attachment = MediaRepository.new.attach(@record, @file)
      ServiceResult.success({ media: attachment })
    end
  end
end
