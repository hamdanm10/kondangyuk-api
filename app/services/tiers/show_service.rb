module Tiers
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      tier = TierRepository.new.find_by_id(@id)
      ServiceResult.success({ tier: tier })
    end
  end
end
