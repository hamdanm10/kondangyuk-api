module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user || reject_unauthorized_connection
    end

    private

      # Authenticate the WebSocket the same way HTTP requests are authenticated
      # (see Api::V1::BaseController#require_authentication): resolve the signed
      # session_token cookie the browser sends on the handshake and look it up via
      # SessionRepository, which also enforces the server-side expiry.
      def find_verified_user
        token = cookies.signed[:session_token]
        session = token && SessionRepository.new.find_by_token(token)
        session&.user
      end
  end
end
