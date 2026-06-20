module Api
  module V1
    module Designer
      class BaseController < Api::V1::BaseController
        before_action :require_designer

        private

        def require_designer
          unless current_user.designer?
            render_fail({ base: [ "Forbidden" ] }, :forbidden)
            false
          end
        end
      end
    end
  end
end
