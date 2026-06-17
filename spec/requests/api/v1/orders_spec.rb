require 'swagger_helper'

RSpec.describe 'API V1 Orders', type: :request do
  path '/api/v1/orders' do
    get 'List all orders' do
      tags        'Admin | Orders'
      produces    'application/json'
      description 'Returns all orders with pagination. Accessible by admin or super_admin.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'orders returned' do
        let(:admin) { create(:user) }
        before do
          create_list(:order, 3)
          login_as(admin)
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
                           id:     { type: :integer },
                           price:  { type: :string },
                           status: { type: :string, example: 'pending' },
                           template: {
                             type: :object,
                             properties: { id: { type: :integer }, slug: { type: :string }, name: { type: :string } }
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
    end

    post 'Create order' do
      tags        'Admin | Orders'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates an order for a template (status defaults to pending). Accessible by admin or super_admin.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              template_id: { type: :integer },
              price:       { type: :number, example: 150_000 },
              status:      { type: :string, enum: %w[pending working review completed], example: 'pending' }
            },
            required: %w[template_id price]
          }
        }
      }

      response '201', 'order created' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:body) { { order: { template_id: template.id, price: 150_000 } } }
        before { login_as(admin) }

        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     order: {
                       type: :object,
                       properties: {
                         id:     { type: :integer },
                         price:  { type: :string },
                         status: { type: :string },
                         template: { type: :object },
                         created_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '422', 'validation failed' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:body) { { order: { template_id: template.id, price: -1, status: 'bogus' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { order: { template_id: 1, price: 1 } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}' do
    get 'Show order' do
      tags 'Admin | Orders'
      produces 'application/json'
      description 'Returns a single order by ID. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order returned' do
        let(:admin) { create(:user) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'order not found' do
        let(:admin) { create(:user) }
        let(:id) { 0 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    patch 'Update order' do
      tags 'Admin | Orders'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates an order (price and/or status) by ID. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              template_id: { type: :integer },
              price:       { type: :number },
              status:      { type: :string, enum: %w[pending working review completed] }
            }
          }
        }
      }

      response '200', 'order updated' do
        let(:admin) { create(:user) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        # Partial update (status only) must not clobber price/template_id.
        let(:body) { { order: { status: 'working' } } }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'invalid status' do
        let(:admin) { create(:user) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        let(:body) { { order: { template_id: order.template_id, price: 1, status: 'bogus' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'order not found' do
        let(:admin) { create(:user) }
        let(:id) { 0 }
        let(:body) { { order: { price: 1 } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { order: { price: 1 } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete order' do
      tags 'Admin | Orders'
      produces 'application/json'
      description 'Permanently deletes an order by ID (hard delete). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order deleted' do
        let(:admin) { create(:user) }
        let(:order) { create(:order) }
        let(:id) { order.id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'order not found' do
        let(:admin) { create(:user) }
        let(:id) { 0 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
