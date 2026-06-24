module Marketplaces
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo        = MarketplaceRepository.new
      marketplace = repo.find_by_id(@id)
      repo.soft_delete(marketplace)
      ServiceResult.success({})
    end
  end
end
