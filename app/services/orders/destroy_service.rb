module Orders
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo  = OrderRepository.new
      order = repo.find_by_id(@id)
      repo.delete_order(order)
      ServiceResult.success({})
    end
  end
end
