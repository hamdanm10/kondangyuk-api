class AddDeletedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    # Orders are crucial data, so deletion is soft (sets deleted_at) instead of removing the row.
    add_column :orders, :deleted_at, :timestamp
  end
end
