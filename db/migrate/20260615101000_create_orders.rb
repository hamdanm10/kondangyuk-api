class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_enum :order_status, %w[pending working review completed]

    create_table :orders do |t|
      t.references :template, null: false, foreign_key: true
      t.decimal    :price,    null: false, precision: 10, scale: 2
      t.enum       :status,   enum_type: :order_status, null: false, default: "pending"

      t.timestamps
    end
  end
end
