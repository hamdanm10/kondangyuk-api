module Api
  module V1
    class SuperAdmin::UserActivationsController < Api::V1::SuperAdmin::BaseController
      def create
        result = Users::ActivateService.call(id: params[:user_id])
        if result.success?
          @user = result.data[:user]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        result = Users::DeactivateService.call(id: params[:user_id])
        if result.success?
          @user = result.data[:user]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end
    end
  end
end
