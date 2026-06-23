module Authentication
  class LoginService < BaseService
    INVALID_CREDENTIALS = { credentials: [ "invalid email or password" ] }.freeze
    ACCOUNT_DEACTIVATED = { account: [ "is deactivated" ] }.freeze

    # Pre-computed bcrypt digest used to equalize response time when the email
    # is not found, so timing cannot reveal whether the email is registered.
    DUMMY_DIGEST = BCrypt::Password.create("invalid-password").freeze

    def initialize(params:, ip_address: nil, user_agent: nil)
      @params = params
      @ip_address = ip_address
      @user_agent = user_agent
    end

    def call
      user = UserRepository.new.find_by_email(@params[:email].to_s)

      # Return an identical error for a missing email and a wrong password to
      # prevent user enumeration; the dummy comparison keeps timing constant.
      authenticated = user ? user.authenticate(@params[:password].to_s) : dummy_authenticate
      return ServiceResult.failure(INVALID_CREDENTIALS) unless authenticated

      # Checked only after a valid password so deactivated accounts are not revealed
      # to attackers probing with wrong passwords.
      return ServiceResult.failure(ACCOUNT_DEACTIVATED) unless user.is_active?

      session_repository = SessionRepository.new
      # Enforce single active session per account: drop any existing sessions so
      # logging in on a new device signs the previous device out.
      session_repository.destroy_all_for_user(user.id)

      session = session_repository.create_session(
        user: user,
        ip_address: @ip_address,
        user_agent: @user_agent
      )

      ServiceResult.success({ user: user, token: session.token })
    end

    private

    def dummy_authenticate
      BCrypt::Password.new(DUMMY_DIGEST).is_password?(@params[:password].to_s)
      false
    end
  end
end
