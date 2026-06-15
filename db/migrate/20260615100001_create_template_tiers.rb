class CreateTemplateTiers < ActiveRecord::Migration[8.1]
  def change
    create_table :template_tiers do |t|
      t.references :template, null: false, foreign_key: true, index: { unique: true }
      t.references :tier,     null: false, foreign_key: true
    end
  end
end
