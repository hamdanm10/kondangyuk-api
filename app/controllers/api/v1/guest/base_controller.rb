module Api
  module V1
    module Guest
      class BaseController < Api::V1::BaseController
        skip_before_action :require_authentication
      end
    end
  end
end
