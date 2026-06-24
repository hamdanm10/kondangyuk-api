module Api
  module V1
    module SuperAdmin
      class BaseController < Api::V1::BaseController
        before_action :require_super_admin

        private

        def require_super_admin
          unless current_user.super_admin?
            render_fail({ base: [ I18n.t("messages.errors.forbidden") ] }, :forbidden)
            false
          end
        end
      end
    end
  end
end
