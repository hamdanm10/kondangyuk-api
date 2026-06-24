module Profiles
  class UpdateService < BaseService
    def initialize(user:, params:)
      @user   = user
      @params = params
    end

    def call
      invalid = invalid_current_password || invalid_password_confirmation
      return invalid if invalid

      user = UserRepository.new.update_user(@user, attributes)
      ServiceResult.success({ user: user })
    end

    private

    # A new password may only be set when the user proves knowledge of the current one.
    def invalid_current_password
      return nil unless changing_password?
      return nil if @user.authenticate(@params[:current_password])

      ServiceResult.failure(current_password: [ "is invalid" ])
    end

    # A new password must be repeated identically in password_confirmation.
    def invalid_password_confirmation
      return nil unless changing_password?
      return nil if @params[:password] == @params[:password_confirmation]

      ServiceResult.failure(password_confirmation: [ "doesn't match Password" ])
    end

    def changing_password?
      @params[:password].present?
    end

    def attributes
      attrs = { full_name: @params[:full_name], email: @params[:email] }.compact
      if changing_password?
        attrs[:password] = @params[:password]
        attrs[:password_confirmation] = @params[:password_confirmation]
      end
      attrs
    end
  end
end
