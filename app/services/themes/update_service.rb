module Themes
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo  = ThemeRepository.new
      theme = repo.find_by_id(@id)
      theme = repo.update_theme(theme, name: @params[:name])
      ServiceResult.success({ theme: theme })
    end
  end
end
