require 'swagger_helper'

RSpec.describe 'API V1 Tiers', type: :request do
  path '/api/v1/super_admin/tiers' do
    get 'List all tiers' do
      tags        'Super Admin | Tiers'
      produces    'application/json'
      description 'Returns all tiers with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'

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
                           id:         { type: :integer },
                           name:       { type: :string },
                           price:      { type: :string },
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

    post 'Create tier' do
      tags        'Super Admin | Tiers'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a new tier. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          tier: {
            type: :object,
            properties: {
              name:  { type: :string,  example: 'Gold' },
              price: { type: :number,  example: 99_000 }
            },
            required: %w[name price]
          }
        }
      }

      response '201', 'tier created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { tier: { name: 'Gold', price: 99_000 } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     tier: {
                       type: :object,
                       properties: {
                         id:         { type: :integer },
                         name:       { type: :string },
                         price:      { type: :string },
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
        let(:body) { { tier: { name: '', price: nil } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { tier: { name: 'Gold', price: 99_000 } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { tier: { name: 'Gold', price: 99_000 } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/super_admin/tiers/{id}' do
    get 'Show tier' do
      tags        'Super Admin | Tiers'
      produces    'application/json'
      description 'Returns a single tier by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Tier ID'

      response '200', 'tier returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:tier) { create(:tier) }
        let(:id) { tier.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     tier: {
                       type: :object,
                       properties: {
                         id:         { type: :integer },
                         name:       { type: :string },
                         price:      { type: :string },
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'tier not found' do
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

    patch 'Update tier' do
      tags        'Super Admin | Tiers'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates a tier by ID. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Tier ID'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          tier: {
            type: :object,
            properties: {
              name:  { type: :string, example: 'Platinum' },
              price: { type: :number, example: 199_000 }
            },
            required: %w[name price]
          }
        }
      }

      response '200', 'tier updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:tier) { create(:tier) }
        let(:id) { tier.id }
        let(:body) { { tier: { name: 'Platinum', price: 199_000 } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     tier: {
                       type: :object,
                       properties: {
                         id:         { type: :integer },
                         name:       { type: :string },
                         price:      { type: :string },
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
        let(:tier) { create(:tier) }
        let(:id) { tier.id }
        let(:body) { { tier: { name: '', price: nil } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'tier not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { tier: { name: 'Platinum', price: 199_000 } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { tier: { name: 'Platinum', price: 199_000 } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { tier: { name: 'Platinum', price: 199_000 } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete tier' do
      tags        'Super Admin | Tiers'
      produces    'application/json'
      description 'Soft deletes a tier by ID (sets deleted_at). Record is retained in the database and excluded from all queries. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'Tier ID'

      response '200', 'tier deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:tier) { create(:tier) }
        let(:id) { tier.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test!
      end

      response '404', 'tier not found' do
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
