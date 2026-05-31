module Api
  module V1
    class AdminApplicationController < BaseController
      before_action :require_admin_or_super_admin

      private

      def require_admin_or_super_admin
        unless current_user.admin? || current_user.super_admin?
          render_fail({ base: [ "Forbidden" ] }, :forbidden)
          false
        end
      end
    end
  end
end
