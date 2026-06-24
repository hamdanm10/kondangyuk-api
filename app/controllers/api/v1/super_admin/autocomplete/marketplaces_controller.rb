module Api
  module V1
    module SuperAdmin
      module Autocomplete
        class MarketplacesController < Api::V1::SuperAdmin::BaseController
          def index
            result        = Marketplaces::AutocompleteService.call(query: search_params)
            @marketplaces = result.data[:collection]
            render_success(nil, :ok)
          end

          private

          def search_params
            params.fetch(:q, {}).permit(:name_cont)
          end
        end
      end
    end
  end
end
