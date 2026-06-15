module Templates
  class ListService < BaseService
    def call
      collection = TemplateRepository.new.list_all
      ServiceResult.success({ collection: collection })
    end
  end
end
