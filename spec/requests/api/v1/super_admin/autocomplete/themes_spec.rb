require 'swagger_helper'

RSpec.describe 'API V1 Autocomplete Themes', type: :request do
  path '/api/v1/super_admin/autocomplete/themes' do
    get 'Theme autocomplete' do
      tags        'Super Admin | Autocomplete'
      produces    'application/json'
      description 'Lightweight theme lookup for select/autocomplete inputs. Returns id and name ' \
                  'only, capped at 10 results, searchable by name via ransack. Super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Filter themes by name (case-insensitive contains)'

      response '200', 'themes returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:theme, 3)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     themes: {
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
          theme = JSON.parse(response.body)['data']['themes'].first
          expect(theme.keys).to match_array(%w[id name])
        end
      end

      response '200', 'themes filtered by name and capped at 10' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'auto' }
        before do
          12.times { |i| create(:theme, name: "Autotheme #{i}") }
          create(:theme, name: 'Unrelated')
          login_as(super_admin)
        end

        schema type: :object,
               properties: { status: { type: :string }, data: { type: :object } }

        run_test! do |response|
          themes = JSON.parse(response.body)['data']['themes']
          expect(themes.length).to eq(10)
          expect(themes.map { |t| t['name'] }).to all(include('Autotheme'))
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
