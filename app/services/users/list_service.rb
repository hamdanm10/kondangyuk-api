module Users
  class ListService < BaseService
    def initialize(query: {})
      @query = query
    end

    def call
      collection = UserRepository.new.list_non_super_admins(@query)
      ServiceResult.success({ collection: collection })
    end
  end
end
