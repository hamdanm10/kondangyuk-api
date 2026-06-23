require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  path '/api/v1/super_admin/users' do
    get 'List users' do
      tags        'Super Admin | Users'
      produces    'application/json'
      description 'Returns all users except super_admins, paginated. Searchable by name and ' \
                  'filterable by active state via ransack. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
      parameter name: 'q[full_name_cont]', in: :query, type: :string, required: false,
                description: 'Search by name (case-insensitive contains)'
      parameter name: 'q[is_active_eq]', in: :query, type: :boolean, required: false,
                description: 'Filter by active state (true = active, false = inactive)'

      response '200', 'users returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create(:user, role: :admin)
          create(:user, role: :designer)
          login_as(super_admin)
        end

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
                           full_name:  { type: :string },
                           email:      { type: :string },
                           role:       { type: :string, example: 'admin' },
                           is_active:  { type: :boolean, example: true },
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

        run_test! do |response|
          roles = JSON.parse(response.body)['data']['users'].map { |u| u['role'] }
          expect(roles).to all(satisfy { |r| r != 'super_admin' })
          expect(roles).to contain_exactly('admin', 'designer')
        end
      end

      response '200', 'users filtered by name and active state' do
        let(:super_admin)        { create(:user, :super_admin) }
        let(:'q[full_name_cont]') { 'jane' }
        let(:'q[is_active_eq]')   { true }
        before do
          create(:user, full_name: 'Jane Active',   is_active: true)
          create(:user, full_name: 'Jane Inactive', is_active: false)
          create(:user, full_name: 'John Active',    is_active: true)
          login_as(super_admin)
        end

        schema type: :object,
               properties: { status: { type: :string }, data: { type: :object } }

        run_test! do |response|
          names = JSON.parse(response.body)['data']['users'].map { |u| u['full_name'] }
          expect(names).to eq([ 'Jane Active' ])
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

    post 'Create user' do
      tags        'Super Admin | Users'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a new user with any role except super_admin (defaults to admin when ' \
                  'omitted). Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              full_name: { type: :string, example: 'New Admin' },
              email:     { type: :string, example: 'newadmin@kondangyuk.test' },
              password:  { type: :string, example: 'Password12345!' },
              role:      { type: :string, enum: %w[admin designer], example: 'admin' }
            },
            required: %w[full_name email password]
          }
        }
      }

      response '201', 'user created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) do
          { user: { full_name: 'New Designer', email: 'newdesigner@kondangyuk.test',
                    password: 'Password12345!', role: 'designer' } }
        end
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
                         full_name:  { type: :string },
                         email:      { type: :string },
                         role:       { type: :string, example: 'designer' },
                         is_active:  { type: :boolean, example: true },
                         created_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'user', 'role')).to eq('designer')
        end
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { user: { email: 'invalid-email', password: 'short' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '422', 'super_admin role not allowed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) do
          { user: { full_name: 'Nope', email: 'nope@kondangyuk.test',
                    password: 'Password12345!', role: 'super_admin' } }
        end
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'role')).to be_present
        end
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
