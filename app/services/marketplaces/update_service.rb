module Marketplaces
  class UpdateService < BaseService
    def initialize(id:, params:)
      @id     = id
      @params = params
    end

    def call
      repo        = MarketplaceRepository.new
      marketplace = repo.find_by_id(@id)
      marketplace = repo.update_marketplace(marketplace, name: @params[:name])
      ServiceResult.success({ marketplace: marketplace })
    end
  end
end
