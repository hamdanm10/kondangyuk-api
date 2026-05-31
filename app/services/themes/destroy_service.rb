module Themes
  class DestroyService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      repo = ThemeRepository.new
      theme = repo.find_by_id(@id)
      repo.soft_delete(theme)
      ServiceResult.success({})
    end
  end
end
