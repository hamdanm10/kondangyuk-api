module Templates
  class PublishService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo     = TemplateRepository.new
      template = repo.find_by_id_or_slug(@id)
      template = repo.set_published(template, published_at: Time.current)
      ServiceResult.success({ template: template })
    end
  end
end
