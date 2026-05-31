require 'swagger_helper'

RSpec.describe 'API V1 Themes', type: :request do
  path '/api/v1/themes' do
    get 'List all themes' do
      tags        'Super Admin'
      produces    'application/json'
      description 'Returns all themes with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page (default: 10, max: 100)'

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
                           id:         { type: :integer },
                           name:       { type: :string },
                           created_at: { type: :string, format: 'date-time' }
                         }
                       }
                     },
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer, example: 1 },
                         total_pages:  { type: :integer, example: 1 },
                         total_count:  { type: :integer, example: 3 },
                         prev_page:    { type: :integer, nullable: true, example: nil },
                         next_page:    { type: :integer, nullable: true, example: nil },
                         limit:        { type: :integer, example: 10 }
                       }
                     }
                   }
                 }
               }

        run_test!
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

    post 'Create theme' do
      tags        'Super Admin'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a new theme. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          theme: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Dark Mode' }
            },
            required: %w[name]
          }
        }
      }

      response '201', 'theme created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { theme: { name: 'Dark Mode' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     theme: {
                       type: :object,
                       properties: {
                         id:         { type: :integer },
                         name:       { type: :string },
                         created_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { theme: { name: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { theme: { name: 'Dark Mode' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { theme: { name: 'Dark Mode' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
