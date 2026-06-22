require 'swagger_helper'

RSpec.describe 'API V1 Themes', type: :request do
  path '/api/v1/super_admin/themes' do
    get 'List all themes' do
      tags        'Super Admin | Themes'
      produces    'application/json'
      description 'Returns all themes with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
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

      response '200', 'themes filtered by name' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'Dark' }
        before do
          create(:theme, name: 'Dark Mode')
          create(:theme, name: 'Light Mode')
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
                     pagination: { type: :object }
                   }
                 }
               }

        run_test! do |response|
          names = JSON.parse(response.body)['data']['themes'].map { |t| t['name'] }
          expect(names).to eq([ 'Dark Mode' ])
        end
      end

      response '200', 'limit falls back to default when not allowed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:limit) { 999 }
        before do
          create_list(:theme, 3)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test! do |response|
          limit_used = JSON.parse(response.body)['data']['pagination']['limit']
          expect(limit_used).to eq(10)
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

    post 'Create theme' do
      tags        'Super Admin | Themes'
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

  path '/api/v1/super_admin/themes/{id}' do
    get 'Show theme' do
      tags        'Super Admin | Themes'
      produces    'application/json'
      description 'Returns a single theme by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Theme ID'

      response '200', 'theme returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:theme) { create(:theme) }
        let(:id) { theme.id }
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
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'theme not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    patch 'Update theme' do
      tags        'Super Admin | Themes'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates a theme by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Theme ID'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          theme: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Light Mode' }
            },
            required: %w[name]
          }
        }
      }

      response '200', 'theme updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:theme) { create(:theme) }
        let(:id) { theme.id }
        let(:body) { { theme: { name: 'Light Mode' } } }
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
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:theme) { create(:theme) }
        let(:id) { theme.id }
        let(:body) { { theme: { name: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'theme not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { theme: { name: 'Light Mode' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { theme: { name: 'Light Mode' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { theme: { name: 'Light Mode' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete theme' do
      tags        'Super Admin | Themes'
      produces    'application/json'
      description 'Soft deletes a theme by ID (sets deleted_at). Record is retained in the database and excluded from all queries. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Theme ID'

      response '200', 'theme deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:theme) { create(:theme) }
        let(:id) { theme.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test!
      end

      response '404', 'theme not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
