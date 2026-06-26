module Templates
  class AutocompleteService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = TemplateRepository.new.autocomplete(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
