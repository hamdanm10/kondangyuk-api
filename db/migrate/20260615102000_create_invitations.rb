class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :order, null: false, foreign_key: true
      t.string     :slug,  null: false
      t.string     :name,  null: false
      t.text       :description
      t.timestamp  :published_at
      t.timestamp  :expires_at

      t.timestamps
    end

    add_index :invitations, :slug, unique: true
  end
end
