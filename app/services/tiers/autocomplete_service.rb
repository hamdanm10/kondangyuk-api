module Tiers
  class AutocompleteService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = TierRepository.new.autocomplete(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
