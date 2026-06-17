module Templates
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo     = TemplateRepository.new
      template = repo.find_by_id_or_slug(@id)

      classification = ResolveClassificationService.call(params: @params)
      return classification unless classification.success?

      template = repo.update_template(
        template,
        attrs:       @params.slice(:slug, :name, :description, :published_at),
        themes:      classification.data[:themes],
        tier:        classification.data[:tier],
        sync_themes: classification.data[:sync_themes],
        sync_tier:   classification.data[:sync_tier]
      )
      ServiceResult.success({ template: template })
    end
  end
end
