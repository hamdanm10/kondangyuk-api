require 'swagger_helper'

RSpec.describe 'API V1 Autocomplete Marketplaces', type: :request do
  path '/api/v1/super_admin/autocomplete/marketplaces' do
    get 'Marketplace autocomplete' do
      tags        'Super Admin | Autocomplete'
      produces    'application/json'
      description 'Lightweight marketplace lookup for select/autocomplete inputs. Returns id and ' \
                  'name only, capped at 10 results, searchable by name via ransack. Super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Filter marketplaces by name (case-insensitive contains)'

      response '200', 'marketplaces returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:marketplace, 3)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     marketplaces: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id:   { type: :integer },
                           name: { type: :string }
                         }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          marketplace = JSON.parse(response.body)['data']['marketplaces'].first
          expect(marketplace.keys).to match_array(%w[id name])
        end
      end

      response '200', 'marketplaces filtered by name and capped at 10' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'Shop' }
        before do
          12.times { |i| create(:marketplace, name: "Shopmart #{i}") }
          create(:marketplace, name: 'Unrelated')
          login_as(super_admin)
        end

        schema type: :object,
               properties: { status: { type: :string }, data: { type: :object } }

        run_test! do |response|
          marketplaces = JSON.parse(response.body)['data']['marketplaces']
          expect(marketplaces.length).to eq(10)
          expect(marketplaces.map { |m| m['name'] }).to all(include('Shopmart'))
        end
      end

      response '401', 'not authenticated' do
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
