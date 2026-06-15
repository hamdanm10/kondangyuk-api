module TemplateDocuments
  class DestroyService < BaseService
    def initialize(template_id:)
      @template_id = template_id
    end

    def call
      template = TemplateRepository.new.find_by_id_or_slug(@template_id)
      repo     = TemplateDocumentRepository.new
      document = repo.find_by_template(template)
      repo.delete_document(document)
      ServiceResult.success({})
    end
  end
end
