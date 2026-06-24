module Marketplaces
  class AutocompleteService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = MarketplaceRepository.new.autocomplete(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
