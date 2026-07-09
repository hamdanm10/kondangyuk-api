module Api
  module V1
    class Designer::ProfilesController < Api::V1::Designer::BaseController
      def show
        @user = current_user
        render_success
      end

      def update
        result = Profiles::UpdateService.call(user: current_user, params: profile_params)
        if result.success?
          @user = result.data[:user]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:full_name, :email, :password, :password_confirmation,
                                         :current_password)
      end
    end
  end
end
