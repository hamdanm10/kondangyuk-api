module Templates
  class ShowPublishedService < BaseService
    def initialize(slug:)
      @slug = slug
    end

    def call
      template = TemplateRepository.new.find_published_by_slug(@slug)
      document = TemplateDocumentRepository.new.find_by_template(template)
      ServiceResult.success({ template: template, document: document })
    end
  end
end
