module Users
  class ListService < BaseService
    def call
      collection = UserRepository.new.find_admins
      ServiceResult.success({ collection: collection })
    end
  end
end
