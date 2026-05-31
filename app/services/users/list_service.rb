module Users
  class ListService < BaseService
    def call
      users = UserRepository.new.find_admins
      ServiceResult.success({ users: users })
    end
  end
end
