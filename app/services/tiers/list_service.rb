module Tiers
  class ListService < BaseService
    def call
      collection = TierRepository.new.list_all
      ServiceResult.success({ collection: collection })
    end
  end
end
