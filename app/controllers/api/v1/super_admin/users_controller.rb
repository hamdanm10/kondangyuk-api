module Api
  module V1
    class SuperAdmin::UsersController < Api::V1::SuperAdmin::BaseController
      def index
        result = Users::ListService.call
        @pagy, @users = pagy(:offset, result.data[:collection])
        render_success(nil, :ok)
      end

      def create
        result = Users::CreateService.call(params: user_params)
        if result.success?
          @user = result.data[:user]
          render_success(nil, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
