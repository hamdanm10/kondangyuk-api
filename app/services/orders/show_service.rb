module Orders
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      order = OrderRepository.new.find_by_id(@id)
      ServiceResult.success({ order: order })
    end
  end
end
