require 'swagger_helper'

RSpec.describe 'API V1 Templates', type: :request do
  path '/api/v1/templates' do
    get 'List all templates' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Returns all templates with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page (default: 10, max: 100)'

      response '200', 'templates returned' do
        let(:super_admin) { create(:user, :super_admin) }
        before do
          create_list(:template, 3, created_by_user: super_admin)
          login_as(super_admin)
        end

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     templates: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id:           { type: :integer },
                           slug:         { type: :string },
                           name:         { type: :string },
                           description:  { type: :string, nullable: true },
                           published_at: { type: :string, format: 'date-time', nullable: true },
                           created_at:   { type: :string, format: 'date-time' }
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

    post 'Create template' do
      tags        'Super Admin | Templates'
      consumes    'application/json'
      produces    'application/json'
      description 'Creates a template together with its document (atomic). The MDX document is stored ' \
                  'as-is and rendered by the client. created_by_user is taken from the authenticated ' \
                  'user. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          template: {
            type: :object,
            properties: {
              slug:         { type: :string, example: 'wedding-classic' },
              name:         { type: :string, example: 'Wedding Classic' },
              description:  { type: :string, nullable: true, example: 'A classic theme' },
              published_at: { type: :string, format: 'date-time', nullable: true },
              meta:         { type: :object, example: { title: 'Wedding Classic' } },
              document:     { type: :string, example: "---\ntitle: Wedding\n---\n# Hello" }
            },
            required: %w[slug name document]
          }
        }
      }

      response '201', 'template created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) do
          { template: { slug: 'wedding-classic', name: 'Wedding Classic',
                        meta: { title: 'Wedding Classic' }, document: "---\ntitle: Wedding\n---\n# Hello" } }
        end
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     template: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         description:  { type: :string, nullable: true },
                         published_at: { type: :string, format: 'date-time', nullable: true },
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
        let(:body) { { template: { slug: '', name: '', document: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { template: { slug: 'x', name: 'X', document: '# x' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { template: { slug: 'x', name: 'X', document: '# x' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/templates/{id}' do
    get 'Show template' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Returns a single template (metadata only) by ID or slug. The document detail is ' \
                  'fetched via /api/v1/templates/{id}/document. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :string, required: true,
                description: 'Template ID or slug'

      response '200', 'template returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template) }
        let(:id) { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     template: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         description:  { type: :string, nullable: true },
                         published_at: { type: :string, format: 'date-time', nullable: true },
                         created_at:   { type: :string, format: 'date-time' },
                         updated_at:   { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'template not found' do
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

    patch 'Update template' do
      tags        'Super Admin | Templates'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates template metadata by ID or slug. The document is updated via its own ' \
                  'endpoint. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :string, required: true,
                description: 'Template ID or slug'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          template: {
            type: :object,
            properties: {
              slug:         { type: :string, example: 'wedding-modern' },
              name:         { type: :string, example: 'Wedding Modern' },
              description:  { type: :string, nullable: true },
              published_at: { type: :string, format: 'date-time', nullable: true }
            },
            required: %w[slug name]
          }
        }
      }

      response '200', 'template updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template) }
        let(:id) { template.id }
        let(:body) { { template: { slug: 'wedding-modern', name: 'Wedding Modern' } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     template: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         description:  { type: :string, nullable: true },
                         published_at: { type: :string, format: 'date-time', nullable: true },
                         created_at:   { type: :string, format: 'date-time' },
                         updated_at:   { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template) }
        let(:id) { template.id }
        let(:body) { { template: { slug: '', name: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'template not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:id) { 0 }
        let(:body) { { template: { slug: 'x', name: 'X' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:id) { 1 }
        let(:body) { { template: { slug: 'x', name: 'X' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:id) { 1 }
        let(:body) { { template: { slug: 'x', name: 'X' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete template' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Soft deletes a template by ID or slug (sets deleted_at). Record is retained in the ' \
                  'database and excluded from all queries. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :id, in: :path, type: :string, required: true,
                description: 'Template ID or slug'

      response '200', 'template deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template) }
        let(:id) { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test!
      end

      response '404', 'template not found' do
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

  describe 'lookup by slug' do
    let(:super_admin) { create(:user, :super_admin) }
    let!(:template) { create(:template, slug: 'wedding-classic') }
    before { login_as(super_admin) }

    it 'resolves GET /api/v1/templates/:slug' do
      get '/api/v1/templates/wedding-classic', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'template', 'slug')).to eq('wedding-classic')
    end
  end
end
