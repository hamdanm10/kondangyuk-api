module Marketplaces
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      marketplace = MarketplaceRepository.new.create_marketplace(name: @params[:name])
      ServiceResult.success({ marketplace: marketplace })
    end
  end
end
