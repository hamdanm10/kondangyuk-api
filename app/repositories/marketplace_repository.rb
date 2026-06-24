class MarketplaceRepository < BaseRepository
  def list_all(query = {})
    Marketplace.active.ransack(query).result.order(:name)
  end

  def autocomplete(query = {})
    Marketplace.active.ransack(query).result.order(:name).limit(10).select(:id, :name)
  end

  def create_marketplace(name:)
    Marketplace.create!(name: name)
  end

  def find_by_id(id)
    Marketplace.active.find(id)
  end

  def update_marketplace(marketplace, name:)
    marketplace.update!(name: name)
    marketplace
  end

  def soft_delete(marketplace)
    marketplace.update!(deleted_at: Time.current)
  end

  private

  def model
    Marketplace
  end
end
