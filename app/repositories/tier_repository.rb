class TierRepository < BaseRepository
  def list_all(query = {})
    Tier.active.ransack(query).result.order(:name)
  end

  def find_by_id(id)
    Tier.active.find(id)
  end

  def find_active(id)
    Tier.active.find_by(id: id)
  end

  def create_tier(name:, price:)
    Tier.create!(name: name, price: price)
  end

  def update_tier(tier, name:, price:)
    tier.update!(name: name, price: price)
    tier
  end

  def soft_delete(tier)
    tier.update!(deleted_at: Time.current)
  end

  private

  def model
    Tier
  end
end
