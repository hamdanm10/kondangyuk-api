module Api
  module V1
    class SuperAdmin::UsersController < Api::V1::SuperAdmin::BaseController
      def index
        result = Users::ListService.call(query: search_params)
        @pagy, @users = paginate(result.data[:collection])
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
        params.require(:user).permit(:email, :password, :full_name, :role)
      end

      def search_params
        params.fetch(:q, {}).permit(:full_name_cont, :is_active_eq)
      end
    end
  end
end
