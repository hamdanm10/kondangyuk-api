require 'swagger_helper'

RSpec.describe 'API V1 Autocomplete Templates', type: :request do
  path '/api/v1/super_admin/autocomplete/templates' do
    get 'Template autocomplete' do
      tags        'Super Admin | Autocomplete'
      produces    'application/json'
      description 'Lightweight template lookup for select/autocomplete inputs. Returns id, name and ' \
                  'slug only, capped at 10 results, searchable by name via ransack. Only published ' \
                  '(and non-deleted) templates are returned. Super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Filter templates by name (case-insensitive contains)'

      response '200', 'published templates returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create(:template, :published, name: 'Published Classic')
          create(:template, name: 'Draft Classic') # unpublished — must be excluded
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     templates: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id:   { type: :integer },
                           name: { type: :string },
                           slug: { type: :string }
                         }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          names = JSON.parse(response.body)['data']['templates'].map { |t| t['name'] }
          expect(names).to eq([ 'Published Classic' ])
        end
      end

      response '200', 'published templates filtered by name and capped at 10' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'Wedding' }
        before do
          12.times { |i| create(:template, :published, name: "Wedding #{i}") }
          create(:template, :published, name: 'Birthday')
          login_as(super_admin)
        end

        schema type: :object,
               properties: { status: { type: :string }, data: { type: :object } }

        run_test! do |response|
          templates = JSON.parse(response.body)['data']['templates']
          expect(templates.length).to eq(10)
          expect(templates.map { |t| t['name'] }).to all(include('Wedding'))
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
