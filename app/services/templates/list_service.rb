module Templates
  class ListService < BaseService
    def initialize(query: {}, published_only: false)
      @query          = query
      @published_only = published_only
    end

    def call
      collection = TemplateRepository.new.list_all(query: @query, published_only: @published_only)
      ServiceResult.success({ collection: collection })
    end
  end
end
