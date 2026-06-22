module Themes
  class ListService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = ThemeRepository.new.list_all(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
