module Templates
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      template = TemplateRepository.new.find_by_id_or_slug(@id)
      ServiceResult.success({ template: template })
    end
  end
end
