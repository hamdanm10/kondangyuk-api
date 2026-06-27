class OrderRepository < BaseRepository
  def list_all(query = {})
    Order.active.ransack(query).result
         .includes(:template, :marketplace, :invitation)
         .order(created_at: :desc)
  end

  def find_by_id(id)
    Order.active.includes(:template, :marketplace, :invitation).find(id)
  end

  def create_order(attributes)
    Order.transaction do
      order = Order.create!(attributes)
      snapshot_invitation_document(order)
      order
    end
  end

  def update_order(order, attributes)
    order.update!(attributes)
    order
  end

  # Orders are crucial, so they are soft deleted (deleted_at set, row retained). The invitation is
  # soft deleted alongside it, keeping its document and thumbnail.
  def delete_order(order)
    now = Time.current
    Order.transaction do
      order.invitation&.update!(deleted_at: now)
      order.update!(deleted_at: now)
    end
    order
  end

  private

  # The invitation carries a snapshot of the order template's document so later template edits
  # never change an already-placed order. The invitation row itself is created via nested
  # attributes; this copies the document content the nested form can't supply.
  def snapshot_invitation_document(order)
    snapshot = order.template.template_document
    raise ActiveRecord::RecordNotFound, "Template has no document to snapshot" if snapshot.nil?

    order.invitation.create_invitation_document!(meta: snapshot.meta, document: snapshot.document)
  end

  def model
    Order
  end
end
