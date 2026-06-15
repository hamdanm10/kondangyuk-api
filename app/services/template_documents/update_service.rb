module TemplateDocuments
  class UpdateService < BaseService
    def initialize(template_id:, params:)
      @template_id = template_id
      @params      = params
    end

    def call
      template  = TemplateRepository.new.find_by_id_or_slug(@template_id)
      repo      = TemplateDocumentRepository.new
      document  = repo.find_by_template(template)
      document  = repo.update_document(document, meta: @params[:meta], document_body: @params[:document])
      ServiceResult.success({ document: document })
    end
  end
end
