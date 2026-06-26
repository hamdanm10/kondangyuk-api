module Templates
  class UnpublishService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo     = TemplateRepository.new
      template = repo.find_by_id_or_slug(@id)
      template = repo.set_published(template, published_at: nil)
      ServiceResult.success({ template: template })
    end
  end
end
