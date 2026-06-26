module Orders
  class ListService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = OrderRepository.new.list_all(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
