module Api
  module V1
    module SuperAdmin
      module Autocomplete
        class ThemesController < Api::V1::SuperAdmin::BaseController
          def index
            result  = Themes::AutocompleteService.call(query: search_params)
            @themes = result.data[:collection]
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
