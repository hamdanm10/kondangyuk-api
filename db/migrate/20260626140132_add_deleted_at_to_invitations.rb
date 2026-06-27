class AddDeletedAtToInvitations < ActiveRecord::Migration[8.1]
  def change
    # Invitations are soft deleted (sets deleted_at) instead of removing the row, mirroring orders.
    add_column :invitations, :deleted_at, :timestamp
  end
end
