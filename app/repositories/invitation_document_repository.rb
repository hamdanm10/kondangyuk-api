class InvitationDocumentRepository < BaseRepository
  def find_by_invitation(invitation)
    InvitationDocument.find_by!(invitation_id: invitation.id)
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
    InvitationDocument
  end
end
