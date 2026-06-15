module Templates
  class ListService < BaseService
    def initialize(theme_id: nil, tier_id: nil)
      @theme_id = theme_id
      @tier_id  = tier_id
    end

    def call
      collection = TemplateRepository.new.list_all(theme_id: @theme_id, tier_id: @tier_id)
      ServiceResult.success({ collection: collection })
    end
  end
end
