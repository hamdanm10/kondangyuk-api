module Api
  module V1
    class Guest::SessionsController < Api::V1::Guest::BaseController
      rate_limit to: 10, within: 1.minute, only: :create, by: -> { request.remote_ip }

      def create
        result = Authentication::LoginService.call(
          params: session_params,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        if result.success?
          @user = result.data[:user]
          set_session_cookie(result.data[:token])
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        Authentication::LogoutService.call(token: cookies.signed[:session_token].to_s)
        cookies.delete(:session_token)
        head :no_content
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end

      def set_session_cookie(token)
        cookies.signed[:session_token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 30.days.from_now
        }
      end
    end
  end
end
