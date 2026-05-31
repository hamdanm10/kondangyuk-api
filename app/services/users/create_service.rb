module Users
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      user = UserRepository.new.create_user(
        email: @params[:email],
        password: @params[:password],
        role: :admin
      )

      ServiceResult.success({ user: user })
    end
  end
end
