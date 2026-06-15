module Templates
  class CreateService < BaseService
    def initialize(params:, created_by_user:)
      @params          = params
      @created_by_user = created_by_user
    end

    def call
      classification = ResolveClassificationService.call(params: @params)
      return classification unless classification.success?

      template = TemplateRepository.new.create_with_document(
        slug:            @params[:slug],
        name:            @params[:name],
        description:     @params[:description],
        published_at:    @params[:published_at],
        created_by_user: @created_by_user,
        meta:            @params[:meta],
        document:        @params[:document],
        themes:          classification.data[:themes],
        tier:            classification.data[:tier]
      )
      ServiceResult.success({ template: template })
    end
  end
end
