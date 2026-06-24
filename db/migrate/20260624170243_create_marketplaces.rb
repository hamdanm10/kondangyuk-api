class CreateMarketplaces < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplaces do |t|
      t.string    :name,       null: false
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
