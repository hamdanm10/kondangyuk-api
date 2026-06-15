module Api
  module V1
    class TemplateDocumentsController < SuperAdminApplicationController
      def show
        result = TemplateDocuments::ShowService.call(template_id: params[:template_id])
        @document = result.data[:document]
        render_success(nil, :ok)
      end

      def update
        result = TemplateDocuments::UpdateService.call(
          template_id: params[:template_id],
          params:      template_document_params
        )
        if result.success?
          @document = result.data[:document]
          render_success(nil, :ok)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      def destroy
        TemplateDocuments::DestroyService.call(template_id: params[:template_id])
        render_success({}, :ok)
      end

      private

      def template_document_params
        params.require(:template_document).permit(:document, meta: {})
      end
    end
  end
end
