module Users
  class ActivateService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo = UserRepository.new
      user = repo.find_by_id!(@id)
      return ServiceResult.failure(role: [ I18n.t("messages.errors.super_admin_activation") ]) if user.super_admin?

      user = repo.set_active(user, active: true)

      ServiceResult.success({ user: user })
    end
  end
end
