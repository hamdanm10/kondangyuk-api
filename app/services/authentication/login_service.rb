module Authentication
  class LoginService < BaseService
    def initialize(params:, ip_address: nil, user_agent: nil)
      @params = params
      @ip_address = ip_address
      @user_agent = user_agent
    end

    def call
      user = UserRepository.new.find_by_email(@params[:email].to_s)
      return ServiceResult.failure(email: [ "not found" ]) unless user
      return ServiceResult.failure(password: [ "is incorrect" ]) unless user.authenticate(@params[:password].to_s)

      session = SessionRepository.new.create_session(
        user: user,
        ip_address: @ip_address,
        user_agent: @user_agent
      )

      ServiceResult.success({ user: user, token: session.token })
    end
  end
end
