module Users
  class DeactivateService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo = UserRepository.new
      user = repo.find_by_id!(@id)
      return ServiceResult.failure(role: [ I18n.t("messages.errors.super_admin_activation") ]) if user.super_admin?

      user = repo.set_active(user, active: false)
      # Drop any active sessions so a deactivated user is signed out immediately.
      SessionRepository.new.destroy_all_for_user(user.id)

      ServiceResult.success({ user: user })
    end
  end
end
