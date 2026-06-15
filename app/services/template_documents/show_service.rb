module TemplateDocuments
  class ShowService < BaseService
    def initialize(template_id:)
      @template_id = template_id
    end

    def call
      template = TemplateRepository.new.find_by_id_or_slug(@template_id)
      document = TemplateDocumentRepository.new.find_by_template(template)
      ServiceResult.success({ document: document })
    end
  end
end
