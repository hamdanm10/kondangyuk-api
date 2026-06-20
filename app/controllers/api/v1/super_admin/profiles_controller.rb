module Api
  module V1
    class SuperAdmin::ProfilesController < Api::V1::SuperAdmin::BaseController
      def show
        @user = current_user
        render_success
      end
    end
  end
end
