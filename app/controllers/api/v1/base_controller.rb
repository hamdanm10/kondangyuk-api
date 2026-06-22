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

      def paginate(collection)
        limit = Pagination::ResolveLimitService.call(limit: params[:limit]).data[:limit]
        # max_limit: false stops pagy from re-reading params[:limit]; the allowlist
        # is already enforced by ResolveLimitService, so the resolved limit is final.
        pagy(:offset, collection, limit: limit, max_limit: false)
      end
    end
  end
end
