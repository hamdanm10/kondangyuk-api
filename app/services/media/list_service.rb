module Media
  class ListService < BaseService
    def initialize(record:)
      @record = record
    end

    def call
      ServiceResult.success({ media: MediaRepository.new.list(@record) })
    end
  end
end
