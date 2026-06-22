require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  path '/api/v1/super_admin/users' do
    get 'List all admin users' do
      tags        'Super Admin | Users'
      produces    'application/json'
      description 'Returns all users with role admin. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'

      response '200', 'users returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     users: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id:         { type: :integer },
                           email:      { type: :string },
                           role:       { type: :string, example: 'admin' },
                           created_at: { type: :string, format: 'date-time' }
                         }
                       }
                     },
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer, example: 1 },
                         total_pages:  { type: :integer, example: 5 },
                         total_count:  { type: :integer, example: 100 },
                         prev_page:    { type: :integer, nullable: true, example: nil },
                         next_page:    { type: :integer, nullable: true, example: 2 },
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

    post 'Create admin user' do
      tags        'Super Admin | Users'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a new user with role admin. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email:    { type: :string, example: 'newadmin@kondangyuk.test' },
              password: { type: :string, example: 'Password12345!' }
            },
            required: %w[email password]
          }
        }
      }

      response '201', 'user created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { user: { email: 'newadmin@kondangyuk.test', password: 'Password12345!' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     user: {
                       type: :object,
                       properties: {
                         id:         { type: :integer },
                         email:      { type: :string },
                         role:       { type: :string, example: 'admin' },
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
        let(:body) { { user: { email: 'invalid-email', password: 'short' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { user: { email: 'test@example.com', password: 'Password12345!' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { user: { email: 'test@example.com', password: 'Password12345!' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
