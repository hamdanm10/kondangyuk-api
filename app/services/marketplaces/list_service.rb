module Marketplaces
  class ListService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = MarketplaceRepository.new.list_all(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
