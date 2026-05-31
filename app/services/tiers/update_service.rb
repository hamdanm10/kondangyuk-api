module Tiers
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo = TierRepository.new
      tier = repo.find_by_id(@id)
      tier = repo.update_tier(tier, name: @params[:name], price: @params[:price])
      ServiceResult.success({ tier: tier })
    end
  end
end
