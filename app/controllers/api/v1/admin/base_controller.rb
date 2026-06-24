module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :require_admin

        private

        def require_admin
          unless current_user.admin?
            render_fail({ base: [ I18n.t("messages.errors.forbidden") ] }, :forbidden)
            false
          end
        end
      end
    end
  end
end
