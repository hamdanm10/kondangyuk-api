module Api
  module V1
    class BaseController < ApplicationController
      before_action :require_authentication

      private

      def require_authentication
        token = cookies.signed[:session_token]
        @current_session = token && SessionRepository.new.find_by_token(token)

        unless @current_session
          render_fail({ base: [ "Not authenticated" ] }, :unauthorized)
          return false
        end

        @current_user = @current_session.user
      end

      def current_user
        @current_user
      end

      def current_session
        @current_session
      end
    end
  end
end
