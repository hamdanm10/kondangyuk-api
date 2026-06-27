class MakeOrdersNumberUniqueIndexPartial < ActiveRecord::Migration[8.1]
  def change
    # Order number is unique per marketplace only among active (non-soft-deleted) orders, so a
    # deleted order's number can be reused. Replace the full unique index with a partial one.
    remove_index :orders, column: [ :marketplace_id, :order_number ], unique: true,
                          name: "index_orders_on_marketplace_id_and_order_number"

    add_index :orders, [ :marketplace_id, :order_number ], unique: true,
                       where: "deleted_at IS NULL",
                       name: "index_orders_on_marketplace_id_and_order_number"
  end
end
