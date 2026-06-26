require 'swagger_helper'

RSpec.describe 'API V1 Order Statuses', type: :request do
  path '/api/v1/super_admin/orders/{order_id}/status' do
    parameter name: :order_id, in: :path, type: :integer, required: true, description: 'Order ID'

    patch 'Change order status' do
      tags        'Super Admin | Orders'
      consumes    'application/json'
      produces    'application/json'
      description 'Changes only the order status (pending|working|review|completed) without sending ' \
                  'the full order form. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'Accept-Language', in: :header, type: :string, required: false,
                description: 'Response language — "id" or "en" (default: en when absent/unsupported)'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              status: { type: :string, enum: %w[pending working review completed], example: 'working' }
            },
            required: %w[status]
          }
        }
      }

      response '200', 'status changed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order)       { create(:order, status: :pending) }
        let(:order_id)    { order.id }
        let(:body)        { { order: { status: 'working' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     order: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         order_number: { type: :string },
                         status:       { type: :string, example: 'working' },
                         updated_at:   { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'order', 'status')).to eq('working')
        end
      end

      response '422', 'invalid status — Indonesian (Accept-Language: id)' do
        let(:super_admin)      { create(:user, :super_admin) }
        let(:'Accept-Language') { 'id' }
        let(:order)            { create(:order) }
        let(:order_id)         { order.id }
        let(:body)             { { order: { status: 'bogus' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'status')).to eq([ 'bukan status pesanan yang valid' ])
        end
      end

      response '404', 'order not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order_id)    { 0 }
        let(:body)        { { order: { status: 'working' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:order_id) { 1 }
        let(:body)     { { order: { status: 'working' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin)    { create(:user) }
        let(:order_id) { 1 }
        let(:body)     { { order: { status: 'working' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
