require 'swagger_helper'

RSpec.describe 'API V1 Autocomplete Tiers', type: :request do
  path '/api/v1/super_admin/autocomplete/tiers' do
    get 'Tier autocomplete' do
      tags        'Super Admin | Autocomplete'
      produces    'application/json'
      description 'Lightweight tier lookup for select/autocomplete inputs. Returns id and name ' \
                  'only, capped at 10 results, searchable by name via ransack. Super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Filter tiers by name (case-insensitive contains)'

      response '200', 'tiers returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:tier, 3)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     tiers: {
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
          tier = JSON.parse(response.body)['data']['tiers'].first
          expect(tier.keys).to match_array(%w[id name])
        end
      end

      response '200', 'tiers filtered by name and capped at 10' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'gold' }
        before do
          12.times { |i| create(:tier, name: "Gold #{i}") }
          create(:tier, name: 'Silver')
          login_as(super_admin)
        end

        schema type: :object,
               properties: { status: { type: :string }, data: { type: :object } }

        run_test! do |response|
          tiers = JSON.parse(response.body)['data']['tiers']
          expect(tiers.length).to eq(10)
          expect(tiers.map { |t| t['name'] }).to all(include('Gold'))
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
