module Api
  module V1
    class ProfilesController < AdminApplicationController
      def show
        @user = current_user
        render_success
      end
    end
  end
end
