module Orders
  class ListService < BaseService
    def call
      collection = OrderRepository.new.list_all
      ServiceResult.success({ collection: collection })
    end
  end
end
