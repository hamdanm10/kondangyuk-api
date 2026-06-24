require 'swagger_helper'

RSpec.describe 'API V1 Marketplaces', type: :request do
  path '/api/v1/super_admin/marketplaces' do
    get 'List all marketplaces' do
      tags        'Super Admin | Marketplaces'
      produces    'application/json'
      description 'Returns all marketplaces with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
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

      response '200', 'marketplaces filtered by name' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[name_cont]') { 'Shop' }
        before do
          create(:marketplace, name: 'Shopee')
          create(:marketplace, name: 'Tokopedia')
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
          names = JSON.parse(response.body)['data']['marketplaces'].map { |m| m['name'] }
          expect(names).to eq([ 'Shopee' ])
        end
      end

      response '200', 'limit falls back to default when not allowed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:limit) { 999 }
        before do
          create_list(:marketplace, 3)
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

    post 'Create marketplace' do
      tags        'Super Admin | Marketplaces'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a new marketplace. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          marketplace: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Shopee' }
            },
            required: %w[name]
          }
        }
      }

      response '201', 'marketplace created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { marketplace: { name: 'Shopee' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     marketplace: {
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
        let(:body) { { marketplace: { name: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { marketplace: { name: 'Shopee' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { marketplace: { name: 'Shopee' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/super_admin/marketplaces/{id}' do
    get 'Show marketplace' do
      tags        'Super Admin | Marketplaces'
      produces    'application/json'
      description 'Returns a single marketplace by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Marketplace ID'

      response '200', 'marketplace returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:marketplace) { create(:marketplace) }
        let(:id) { marketplace.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     marketplace: {
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

      response '404', 'marketplace not found' do
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

    patch 'Update marketplace' do
      tags        'Super Admin | Marketplaces'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates a marketplace by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Marketplace ID'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          marketplace: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Tokopedia' }
            },
            required: %w[name]
          }
        }
      }

      response '200', 'marketplace updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:marketplace) { create(:marketplace) }
        let(:id) { marketplace.id }
        let(:body) { { marketplace: { name: 'Tokopedia' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     marketplace: {
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
        let(:marketplace) { create(:marketplace) }
        let(:id) { marketplace.id }
        let(:body) { { marketplace: { name: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'marketplace not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { marketplace: { name: 'Tokopedia' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { marketplace: { name: 'Tokopedia' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { marketplace: { name: 'Tokopedia' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete marketplace' do
      tags        'Super Admin | Marketplaces'
      produces    'application/json'
      description 'Soft deletes a marketplace by ID (sets deleted_at). Record is retained in the database and excluded from all queries. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Marketplace ID'

      response '200', 'marketplace deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:marketplace) { create(:marketplace) }
        let(:id) { marketplace.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test!
      end

      response '404', 'marketplace not found' do
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
