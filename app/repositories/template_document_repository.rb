class TemplateDocumentRepository < BaseRepository
  def find_by_template(template)
    TemplateDocument.find_by!(template_id: template.id)
  end

  def update_document(document, meta:, document_body:)
    document.update!(meta: meta || {}, document: document_body)
    document
  end

  def delete_document(document)
    document.destroy!
  end

  private

  def model
    TemplateDocument
  end
end
