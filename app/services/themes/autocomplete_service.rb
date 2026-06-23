module Themes
  class AutocompleteService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = ThemeRepository.new.autocomplete(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
