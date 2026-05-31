module Themes
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      theme = ThemeRepository.new.find_by_id(@id)
      ServiceResult.success({ theme: theme })
    end
  end
end
