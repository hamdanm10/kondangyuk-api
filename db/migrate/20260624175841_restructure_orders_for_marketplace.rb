class RestructureOrdersForMarketplace < ActiveRecord::Migration[8.1]
  def change
    # Price is now handled by the source marketplace (Shopee, etc.), not stored here.
    remove_column :orders, :price, :decimal, precision: 10, scale: 2, null: false

    # The marketplace's own order number.
    add_column :orders, :order_number, :string, null: false

    # The marketplace the order originated from. No standalone index — the composite unique index
    # below is led by marketplace_id, so it already serves marketplace_id lookups.
    add_reference :orders, :marketplace, null: false, foreign_key: true, index: false

    # An order number is unique within a marketplace, not across the whole platform.
    add_index :orders, [ :marketplace_id, :order_number ], unique: true
  end
end
