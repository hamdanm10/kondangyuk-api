module Templates
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo     = TemplateRepository.new
      template = repo.find_by_id_or_slug(@id)
      template = repo.update_template(
        template,
        slug:         @params[:slug],
        name:         @params[:name],
        description:  @params[:description],
        published_at: @params[:published_at]
      )
      ServiceResult.success({ template: template })
    end
  end
end
