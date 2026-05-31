module Authentication
  class LogoutService < BaseService
    def initialize(token:)
      @token = token
    end

    def call
      session = SessionRepository.new.find_by_token(@token.to_s)
      SessionRepository.new.destroy_session(session) if session
      ServiceResult.success
    end
  end
end
