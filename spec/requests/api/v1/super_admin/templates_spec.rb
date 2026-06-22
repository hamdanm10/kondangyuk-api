require 'swagger_helper'

RSpec.describe 'API V1 Templates', type: :request do
  path '/api/v1/super_admin/templates' do
    get 'List all templates' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Returns all templates with pagination. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
      parameter name: :theme_id, in: :query, type: :integer, required: false,
                description: 'Filter by theme id (templates having that theme)'
      parameter name: :tier_id, in: :query, type: :integer, required: false,
                description: 'Filter by tier id'

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
                           created_at:   { type: :string, format: 'date-time' },
                           themes: {
                             type: :array,
                             items: {
                               type: :object,
                               properties: { id: { type: :integer }, name: { type: :string } }
                             }
                           },
                           tier: {
                             type: :object, nullable: true,
                             properties: { id: { type: :integer }, name: { type: :string } }
                           }
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
              document:     { type: :string, example: "---\ntitle: Wedding\n---\n# Hello" },
              theme_ids:    { type: :array, items: { type: :integer }, example: [ 1, 2 ] },
              tier_id:      { type: :integer, nullable: true, example: 1 }
            },
            required: %w[slug name document]
          }
        }
      }

      response '201', 'template created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:theme) { create(:theme) }
        let(:tier)  { create(:tier) }
        let(:body) do
          { template: { slug: 'wedding-classic', name: 'Wedding Classic',
                        meta: { title: 'Wedding Classic' }, document: "---\ntitle: Wedding\n---\n# Hello",
                        theme_ids: [ theme.id ], tier_id: tier.id } }
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
                         created_at:   { type: :string, format: 'date-time' },
                         themes: {
                           type: :array,
                           items: {
                             type: :object,
                             properties: { id: { type: :integer }, name: { type: :string } }
                           }
                         },
                         tier: {
                           type: :object, nullable: true,
                           properties: { id: { type: :integer }, name: { type: :string } }
                         }
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

  path '/api/v1/super_admin/templates/{id}' do
    get 'Show template' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Returns a single template (metadata only) by ID or slug. The document detail is ' \
                  'fetched via /api/v1/super_admin/templates/{id}/document. Accessible by super_admin only.'
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
                         updated_at:   { type: :string, format: 'date-time' },
                         themes: {
                           type: :array,
                           items: {
                             type: :object,
                             properties: { id: { type: :integer }, name: { type: :string } }
                           }
                         },
                         tier: {
                           type: :object, nullable: true,
                           properties: { id: { type: :integer }, name: { type: :string } }
                         }
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
              published_at: { type: :string, format: 'date-time', nullable: true },
              theme_ids:    { type: :array, items: { type: :integer }, example: [ 1, 2 ] },
              tier_id:      { type: :integer, nullable: true, example: 1 }
            },
            required: %w[slug name]
          }
        }
      }

      response '200', 'template updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template) }
        let(:id) { template.id }
        let(:theme) { create(:theme) }
        let(:tier)  { create(:tier) }
        let(:body) do
          { template: { slug: 'wedding-modern', name: 'Wedding Modern',
                        theme_ids: [ theme.id ], tier_id: tier.id } }
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
                         created_at:   { type: :string, format: 'date-time' },
                         updated_at:   { type: :string, format: 'date-time' },
                         themes: {
                           type: :array,
                           items: {
                             type: :object,
                             properties: { id: { type: :integer }, name: { type: :string } }
                           }
                         },
                         tier: {
                           type: :object, nullable: true,
                           properties: { id: { type: :integer }, name: { type: :string } }
                         }
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

    it 'resolves GET /api/v1/super_admin/templates/:slug' do
      get '/api/v1/super_admin/templates/wedding-classic', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'template', 'slug')).to eq('wedding-classic')
    end
  end

  describe 'classification' do
    let(:super_admin) { create(:user, :super_admin) }
    let(:json_headers) { { 'ACCEPT' => 'application/json' } }
    before { login_as(super_admin) }

    it 'syncs themes and tier on update and embeds them in the response' do
      template = create(:template)
      themes   = create_list(:theme, 2)
      tier     = create(:tier)

      patch "/api/v1/super_admin/templates/#{template.id}", headers: json_headers,
            params: { template: { slug: template.slug, name: template.name,
                                  theme_ids: themes.map(&:id), tier_id: tier.id } }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body).dig('data', 'template')
      expect(data['themes'].map { |t| t['id'] }).to match_array(themes.map(&:id))
      expect(data.dig('tier', 'id')).to eq(tier.id)
      expect(template.reload.tier).to eq(tier)
    end

    it 'does not clobber fields the partial payload omits' do
      published_at = 1.day.ago.change(usec: 0)
      template = create(:template, description: 'keep me', published_at: published_at)
      theme    = create(:theme)

      # Config-form shape: edits theme/tier, omits published_at; must stay published.
      patch "/api/v1/super_admin/templates/#{template.id}", headers: json_headers,
            params: { template: { slug: template.slug, name: template.name,
                                  description: 'keep me', theme_ids: [ theme.id ] } }
      expect(response).to have_http_status(:ok)
      expect(template.reload.published_at).to eq(published_at)

      # Publish-toggle shape: edits published_at, omits description; must keep it.
      patch "/api/v1/super_admin/templates/#{template.id}", headers: json_headers,
            params: { template: { slug: template.slug, name: template.name, published_at: nil } }
      expect(response).to have_http_status(:ok)
      expect(template.reload.description).to eq('keep me')
      expect(template.themes).to contain_exactly(theme)
    end

    it 'returns 422 when the tier_id is invalid' do
      template = create(:template)

      patch "/api/v1/super_admin/templates/#{template.id}", headers: json_headers,
            params: { template: { slug: template.slug, name: template.name, tier_id: 999_999 } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).dig('data', 'tier_id')).to be_present
    end

    it 'returns 422 when a theme_id is invalid' do
      template = create(:template)

      patch "/api/v1/super_admin/templates/#{template.id}", headers: json_headers,
            params: { template: { slug: template.slug, name: template.name, theme_ids: [ 999_999 ] } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).dig('data', 'theme_ids')).to be_present
    end

    it 'filters the index by theme_id and tier_id (AND)' do
      theme = create(:theme)
      tier  = create(:tier)
      matching = create(:template)
      matching.themes = [ theme ]
      matching.tier   = tier
      other = create(:template)
      other.themes = [ create(:theme) ]
      other.tier   = create(:tier)

      get '/api/v1/super_admin/templates', headers: json_headers, params: { theme_id: theme.id, tier_id: tier.id }

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).dig('data', 'templates').map { |t| t['id'] }
      expect(ids).to eq([ matching.id ])
    end
  end
end
