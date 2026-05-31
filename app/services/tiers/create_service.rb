module Tiers
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      tier = TierRepository.new.create_tier(name: @params[:name], price: @params[:price])
      ServiceResult.success({ tier: tier })
    end
  end
end
