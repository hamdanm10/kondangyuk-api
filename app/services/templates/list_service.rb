module Templates
  class ListService < BaseService
    def initialize(theme_id: nil, tier_id: nil, published_only: false)
      @theme_id       = theme_id
      @tier_id        = tier_id
      @published_only = published_only
    end

    def call
      collection = TemplateRepository.new.list_all(
        theme_id: @theme_id, tier_id: @tier_id, published_only: @published_only
      )
      ServiceResult.success({ collection: collection })
    end
  end
end
