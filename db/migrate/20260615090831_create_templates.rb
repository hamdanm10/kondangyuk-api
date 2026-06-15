class CreateTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :templates do |t|
      t.string     :slug,         null: false
      t.string     :name,         null: false
      t.text       :description
      t.timestamp  :published_at
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.timestamp  :deleted_at

      t.timestamps
    end

    add_index :templates, :slug, unique: true
  end
end
