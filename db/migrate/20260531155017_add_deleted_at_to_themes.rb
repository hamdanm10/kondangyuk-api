class AddDeletedAtToThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :themes, :deleted_at, :datetime
  end
end
