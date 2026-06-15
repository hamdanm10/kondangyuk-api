module Templates
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo     = TemplateRepository.new
      template = repo.find_by_id_or_slug(@id)
      repo.soft_delete(template)
      ServiceResult.success({})
    end
  end
end
