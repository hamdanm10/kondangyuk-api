module Marketplaces
  class ShowService < BaseService
    def initialize(id:)
      @id = id
    end

    def call
      marketplace = MarketplaceRepository.new.find_by_id(@id)
      ServiceResult.success({ marketplace: marketplace })
    end
  end
end
