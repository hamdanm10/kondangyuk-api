class CreateInvitationDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :invitation_documents do |t|
      t.references :invitation, null: false, foreign_key: true, index: { unique: true }
      t.jsonb     :meta,       null: false, default: {}
      t.text      :document,   null: false
    end
  end
end
