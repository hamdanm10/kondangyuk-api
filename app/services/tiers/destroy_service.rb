module Tiers
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo = TierRepository.new
      tier = repo.find_by_id(@id)
      repo.soft_delete(tier)
      ServiceResult.success({})
    end
  end
end
