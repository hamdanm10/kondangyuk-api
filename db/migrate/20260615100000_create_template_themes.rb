class CreateTemplateThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :template_themes do |t|
      t.references :template, null: false, foreign_key: true
      t.references :theme,    null: false, foreign_key: true
    end

    add_index :template_themes, [ :template_id, :theme_id ], unique: true
  end
end
