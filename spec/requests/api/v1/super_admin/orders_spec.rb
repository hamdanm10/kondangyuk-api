require 'swagger_helper'

RSpec.describe 'API V1 Orders', type: :request do
  path '/api/v1/super_admin/orders' do
    get 'List all orders' do
      tags        'Super Admin | Orders'
      produces    'application/json'
      description 'Returns all orders with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'

      response '200', 'orders returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:order, 3)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     orders: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id:           { type: :integer },
                           order_number: { type: :string },
                           status:       { type: :string, example: 'pending' },
                           template: {
                             type: :object,
                             properties: { id: { type: :integer }, slug: { type: :string }, name: { type: :string } }
                           },
                           marketplace: {
                             type: :object,
                             properties: { id: { type: :integer }, name: { type: :string } }
                           },
                           created_at: { type: :string, format: 'date-time' }
                         }
                       }
                     },
                     pagination: { type: :object }
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

    post 'Create order' do
      tags        'Super Admin | Orders'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates an order for a template (status defaults to pending). Price is handled by ' \
                  'the source marketplace, so the order records the marketplace and its order number ' \
                  'instead. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              template_id:    { type: :integer },
              marketplace_id: { type: :integer },
              order_number:   { type: :string, example: 'SHP-123456789' },
              status:         { type: :string, enum: %w[pending working review completed], example: 'pending' }
            },
            required: %w[template_id marketplace_id order_number]
          }
        }
      }

      response '201', 'order created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          { order: { template_id: template.id, marketplace_id: marketplace.id, order_number: 'SHP-123456789' } }
        end
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     order: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         order_number: { type: :string },
                         status:       { type: :string },
                         template:     { type: :object },
                         marketplace:  { type: :object },
                         created_at:   { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template) }
        let(:marketplace) { create(:marketplace) }
        # Missing order_number triggers the presence validation.
        let(:body) { { order: { template_id: template.id, marketplace_id: marketplace.id } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '422', 'invalid status' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          { order: { template_id: template.id, marketplace_id: marketplace.id,
                     order_number: 'SHP-1', status: 'bogus' } }
        end
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'status')).to be_present
        end
      end

      response '401', 'not authenticated' do
        let(:body) { { order: { template_id: 1, marketplace_id: 1, order_number: 'X' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { order: { template_id: 1, marketplace_id: 1, order_number: 'X' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/super_admin/orders/{id}' do
    get 'Show order' do
      tags 'Super Admin | Orders'
      produces 'application/json'
      description 'Returns a single order by ID. Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'order not found' do
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

    patch 'Update order' do
      tags 'Super Admin | Orders'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates an order (template, marketplace, order number and/or status) by ID. ' \
                  'Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              template_id:    { type: :integer },
              marketplace_id: { type: :integer },
              order_number:   { type: :string },
              status:         { type: :string, enum: %w[pending working review completed] }
            }
          }
        }
      }

      response '200', 'order updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        # Partial update (status only) must not clobber marketplace/order_number/template_id.
        let(:body) { { order: { status: 'working' } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'invalid status' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        let(:body) { { order: { template_id: order.template_id, status: 'bogus' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'order not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { order: { status: 'working' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { order: { status: 'working' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { order: { status: 'working' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete order' do
      tags 'Super Admin | Orders'
      produces 'application/json'
      description 'Permanently deletes an order by ID (hard delete). Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'order not found' do
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
