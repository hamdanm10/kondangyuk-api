module Themes
  class ListService < BaseService
    def call
      collection = ThemeRepository.new.list_all
      ServiceResult.success({ collection: collection })
    end
  end
end
