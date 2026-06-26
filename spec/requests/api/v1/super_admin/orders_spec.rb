require 'swagger_helper'

RSpec.describe 'API V1 Orders', type: :request do
  path '/api/v1/super_admin/orders' do
    get 'List all orders' do
      tags        'Super Admin | Orders'
      produces    'application/json'
      description 'Returns all orders (each with its invitation) with pagination, search and ' \
                  'filtering. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
      parameter name: 'q[order_number_cont]',    in: :query, type: :string,  required: false, description: 'Search by order number (case-insensitive contains)'
      parameter name: 'q[invitation_name_cont]', in: :query, type: :string,  required: false, description: 'Search by invitation name (case-insensitive contains)'
      parameter name: 'q[invitation_slug_cont]', in: :query, type: :string,  required: false, description: 'Search by invitation slug (case-insensitive contains)'
      parameter name: 'q[status_eq]',            in: :query, type: :string,  required: false, description: 'Filter by status (pending|working|review|completed)'
      parameter name: 'q[marketplace_id_eq]',    in: :query, type: :integer, required: false, description: 'Filter by marketplace id'
      parameter name: 'q[template_id_eq]',       in: :query, type: :integer, required: false, description: 'Filter by template id'

      response '200', 'orders returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:order, 3, :with_invitation)
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
                           template:     { type: :object },
                           marketplace:  { type: :object },
                           invitation: {
                             type: :object,
                             properties: {
                               id:           { type: :integer },
                               slug:         { type: :string },
                               name:         { type: :string },
                               published_at: { type: :string, nullable: true },
                               expires_at:   { type: :string, nullable: true }
                             }
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

      response '200', 'orders filtered by status' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[status_eq]') { 'working' }
        before do
          create(:order, :with_invitation, status: :working)
          create(:order, :with_invitation, status: :pending)
          login_as(super_admin)
        end

        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |response|
          statuses = JSON.parse(response.body)['data']['orders'].map { |o| o['status'] }
          expect(statuses).to all(eq('working'))
        end
      end

      response '200', 'orders searched by order number' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:'q[order_number_cont]') { 'SHP' }
        before do
          create(:order, :with_invitation, order_number: 'SHP-001')
          create(:order, :with_invitation, order_number: 'TKP-999')
          login_as(super_admin)
        end

        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |response|
          numbers = JSON.parse(response.body)['data']['orders'].map { |o| o['order_number'] }
          expect(numbers).to eq([ 'SHP-001' ])
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

    post 'Create order with its invitation' do
      tags        'Super Admin | Orders'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates an order and its invitation in one atomic call (Order has_one ' \
                  'Invitation). The invitation snapshots the order template document; published_at ' \
                  'starts empty and expires_at is set to 6 months from now. Accessible by ' \
                  'super_admin only.'
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
          },
          invitation: {
            type: :object,
            properties: {
              name:        { type: :string, example: 'Wedding Andi & Sari' },
              slug:        { type: :string, example: 'andi-sari' },
              description: { type: :string, nullable: true, example: 'The wedding of Andi & Sari' }
            },
            required: %w[name slug]
          }
        },
        required: %w[order invitation]
      }

      response '201', 'order and invitation created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template, :with_document) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          {
            order:      { template_id: template.id, marketplace_id: marketplace.id, order_number: 'SHP-123456789' },
            invitation: { name: 'Wedding Andi & Sari', slug: 'andi-sari', description: 'The big day' }
          }
        end
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     order:      { type: :object },
                     invitation: { type: :object }
                   }
                 }
               }
        run_test! do |response|
          invitation = JSON.parse(response.body).dig('data', 'invitation')
          expect(invitation['slug']).to eq('andi-sari')
          expect(invitation['published_at']).to be_nil
          expect(invitation['expires_at']).to be_present
        end
      end

      response '422', 'invalid order — missing order_number' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template, :with_document) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          {
            order:      { template_id: template.id, marketplace_id: marketplace.id },
            invitation: { name: 'Wedding Andi & Sari', slug: 'andi-sari' }
          }
        end
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '422', 'invalid invitation — missing slug' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template, :with_document) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          {
            order:      { template_id: template.id, marketplace_id: marketplace.id, order_number: 'SHP-1' },
            invitation: { name: 'Wedding Andi & Sari' }
          }
        end
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          # Nested attributes prefix the invitation's errors with the association name.
          expect(JSON.parse(response.body).dig('data', 'invitation.slug')).to be_present
        end
      end

      response '422', 'invalid status' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template)    { create(:template, :with_document) }
        let(:marketplace) { create(:marketplace) }
        let(:body) do
          {
            order:      { template_id: template.id, marketplace_id: marketplace.id, order_number: 'SHP-1', status: 'bogus' },
            invitation: { name: 'Wedding Andi & Sari', slug: 'andi-sari' }
          }
        end
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) do
          { order: { template_id: 1, marketplace_id: 1, order_number: 'X' }, invitation: { name: 'N', slug: 's' } }
        end
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) do
          { order: { template_id: 1, marketplace_id: 1, order_number: 'X' }, invitation: { name: 'N', slug: 's' } }
        end
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
      description 'Returns a single order with its invitation by ID. Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, :with_invitation) }
        let(:id) { order.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'invitation', 'id')).to be_present
        end
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

    patch 'Update order with its invitation' do
      tags 'Super Admin | Orders'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates an order and its invitation in one atomic call. Fields are PATCH-style: ' \
                  'only those sent are changed. Accessible by super_admin only.'
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
          },
          invitation: {
            type: :object,
            properties: {
              name:        { type: :string },
              slug:        { type: :string },
              description: { type: :string, nullable: true }
            }
          }
        },
        required: %w[order invitation]
      }

      response '200', 'order updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, :with_invitation) }
        let(:id) { order.id }
        let(:body) { { order: { status: 'working' }, invitation: { name: 'Wedding Budi & Wati' } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |response|
          data = JSON.parse(response.body)['data']
          expect(data.dig('order', 'status')).to eq('working')
          expect(data.dig('invitation', 'name')).to eq('Wedding Budi & Wati')
        end
      end

      response '422', 'invalid status' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, :with_invitation) }
        let(:id) { order.id }
        let(:body) { { order: { status: 'bogus' }, invitation: { name: 'X' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'order not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { order: { status: 'working' }, invitation: { name: 'X' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { order: { status: 'working' }, invitation: { name: 'X' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { order: { status: 'working' }, invitation: { name: 'X' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete order' do
      tags 'Super Admin | Orders'
      produces 'application/json'
      description 'Permanently deletes an order by ID (hard delete). Its invitation is deleted too ' \
                  '(cascade). Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'order deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, :with_invitation) }
        let(:id) { order.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |_response|
          expect(Invitation.where(order_id: id)).to be_empty
        end
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
