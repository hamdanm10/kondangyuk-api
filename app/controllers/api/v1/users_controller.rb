module Api
  module V1
    class UsersController < SuperAdminApplicationController
      def index
        result = Users::ListService.call
        @users = result.data[:users]
        render_success(nil, :ok)
      end
    end
  end
end
