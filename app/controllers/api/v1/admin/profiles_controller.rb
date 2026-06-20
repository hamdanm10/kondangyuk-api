module Api
  module V1
    class Admin::ProfilesController < Api::V1::Admin::BaseController
      def show
        @user = current_user
        render_success
      end
    end
  end
end
