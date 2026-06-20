require 'swagger_helper'

RSpec.describe 'API V1 Invitations', type: :request do
  path '/api/v1/super_admin/invitations' do
    get 'List all invitations' do
      tags 'Super Admin | Invitations'
      produces 'application/json'
      description 'Returns all invitations with pagination. Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :page,  in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response '200', 'invitations returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:invitation, 2)
          login_as(super_admin)
        end
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
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

    post 'Create invitation (snapshot of the order template)' do
      tags 'Super Admin | Invitations'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates an invitation as an immutable snapshot of the order template document ' \
                  '(meta + MDX copied into invitation_document). name/description default to the ' \
                  "template's when omitted. Accessible by super_admin only."
      security [ cookieAuth: [] ]
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          invitation: {
            type: :object,
            properties: {
              order_id:     { type: :integer },
              slug:         { type: :string, example: 'andi-and-budi' },
              name:         { type: :string, nullable: true },
              description:  { type: :string, nullable: true },
              published_at: { type: :string, format: 'date-time', nullable: true },
              expires_at:   { type: :string, format: 'date-time', nullable: true }
            },
            required: %w[order_id slug]
          }
        }
      }

      response '201', 'invitation created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, template: create(:template, :with_document)) }
        let(:body) { { invitation: { order_id: order.id, slug: 'andi-and-budi' } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:order) { create(:order, template: create(:template, :with_document)) }
        let(:body) { { invitation: { order_id: order.id, slug: '' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'order not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { invitation: { order_id: 0, slug: 'x' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { invitation: { order_id: 1, slug: 'x' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { invitation: { order_id: 1, slug: 'x' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/super_admin/invitations/{id}' do
    get 'Show invitation' do
      tags 'Super Admin | Invitations'
      produces 'application/json'
      description 'Returns a single invitation by ID or slug. Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true, description: 'Invitation ID or slug'

      response '200', 'invitation returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation) }
        let(:id) { invitation.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'invitation not found' do
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

    patch 'Update invitation' do
      tags 'Super Admin | Invitations'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates invitation metadata by ID or slug. Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          invitation: {
            type: :object,
            properties: {
              slug:         { type: :string },
              name:         { type: :string },
              description:  { type: :string, nullable: true },
              published_at: { type: :string, format: 'date-time', nullable: true },
              expires_at:   { type: :string, format: 'date-time', nullable: true }
            },
            required: %w[slug name]
          }
        }
      }

      response '200', 'invitation updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation) }
        let(:id) { invitation.id }
        let(:body) { { invitation: { slug: 'updated-slug', name: 'Updated', published_at: Time.current } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation) }
        let(:id) { invitation.id }
        let(:body) { { invitation: { slug: '', name: '' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'invitation not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { invitation: { slug: 'x', name: 'X' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { invitation: { slug: 'x', name: 'X' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { invitation: { slug: 'x', name: 'X' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete invitation' do
      tags 'Super Admin | Invitations'
      produces 'application/json'
      description 'Permanently deletes an invitation by ID or slug (hard delete, cascades to its ' \
                  'document). Accessible by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true

      response '200', 'invitation deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:id) { invitation.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'invitation not found' do
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

  describe 'snapshot behaviour' do
    let(:super_admin) { create(:user, :super_admin) }
    before { login_as(super_admin) }

    it 'copies the template document meta + body into the invitation document' do
      template = create(:template, :with_document)
      template.template_document.update!(meta: { 'theme' => 'rustic' }, document: '# Snapshot me')
      order = create(:order, template: template)

      post '/api/v1/super_admin/invitations', headers: { 'ACCEPT' => 'application/json' },
           params: { invitation: { order_id: order.id, slug: 'snap-1' } }

      expect(response).to have_http_status(:created)
      invitation = Invitation.find_by(slug: 'snap-1')
      expect(invitation.invitation_document.meta).to eq({ 'theme' => 'rustic' })
      expect(invitation.invitation_document.document).to eq('# Snapshot me')
    end
  end
end
