module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :require_admin

        private

        def require_admin
          unless current_user.admin?
            render_fail({ base: [ "Forbidden" ] }, :forbidden)
            false
          end
        end
      end
    end
  end
end
