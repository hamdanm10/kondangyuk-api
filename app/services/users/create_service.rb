module Users
  class CreateService < BaseService
    DEFAULT_ROLE = "admin".freeze

    def initialize(params:)
      @params = params
    end

    def call
      role = @params[:role].presence || DEFAULT_ROLE
      return ServiceResult.failure(role: [ I18n.t("messages.errors.role_not_allowed") ]) unless allowed_roles.include?(role)

      user = UserRepository.new.create_user(
        email: @params[:email],
        password: @params[:password],
        full_name: @params[:full_name],
        role: role
      )

      ServiceResult.success({ user: user })
    end

    private

    # Any role the enum defines except super_admin, which is never created here.
    def allowed_roles
      User.roles.keys - [ "super_admin" ]
    end
  end
end
