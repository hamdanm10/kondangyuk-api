require 'swagger_helper'

RSpec.describe 'API V1 Public Templates', type: :request do
  path '/api/v1/guest/templates' do
    get 'List published templates (public catalog)' do
      tags        'Public | Templates'
      produces    'application/json'
      description 'Public template catalog — returns published templates (those with a published_at) ' \
                  'with pagination, optionally filtered by theme or tier. No authentication required. ' \
                  'Unpublished/draft templates are excluded.'

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page — allowed: 10, 30, 50 (other/over → 10)'
      parameter name: 'q[name_or_slug_cont]', in: :query, type: :string, required: false,
                description: 'Search by name or slug (case-insensitive contains)'
      parameter name: 'q[themes_id_eq]', in: :query, type: :integer, required: false,
                description: 'Filter by theme id (templates having that theme)'
      parameter name: 'q[tier_id_eq]', in: :query, type: :integer, required: false,
                description: 'Filter by tier id'

      response '200', 'templates returned' do
        before { create_list(:template, 3, :published) }

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
                           thumbnail_url: { type: :string, nullable: true },
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
    end
  end

  path '/api/v1/guest/templates/{slug}' do
    get 'Show published template (public detail with document)' do
      tags        'Public | Templates'
      produces    'application/json'
      description 'Public template detail — returns a published template by slug together with its ' \
                  'document (meta + MDX) and thumbnail URL, so the client can render the content. ' \
                  'No authentication required. Unpublished templates, or published templates without a ' \
                  'document, return 404.'

      parameter name: :slug, in: :path, type: :string, required: true, description: 'Template slug'

      response '200', 'template returned' do
        let(:slug) { create(:template, :published, :with_document, slug: 'live-detail').slug }
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
                         thumbnail_url: { type: :string, nullable: true },
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
                         },
                         document: {
                           type: :object,
                           properties: { meta: { type: :object }, document: { type: :string } }
                         }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '404', 'unpublished template' do
        let(:slug) { create(:template, :with_document, slug: 'draft-detail').slug }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'published template without a document' do
        let(:slug) { create(:template, :published, slug: 'no-doc').slug }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  describe 'visibility' do
    it 'lists only published templates and excludes drafts' do
      create(:template, :published, slug: 'live-one', name: 'Live One')
      create(:template, slug: 'draft-one', name: 'Draft One')

      get '/api/v1/guest/templates', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      slugs = JSON.parse(response.body).dig('data', 'templates').map { |t| t['slug'] }
      expect(slugs).to include('live-one')
      expect(slugs).not_to include('draft-one')
    end

    it 'filters published templates by name or slug via ransack' do
      create(:template, :published, slug: 'wedding-classic', name: 'Wedding Classic')
      create(:template, :published, slug: 'birthday-bash',   name: 'Birthday Bash')

      get '/api/v1/guest/templates', params: { q: { name_or_slug_cont: 'wedding' } },
                                     headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      slugs = JSON.parse(response.body).dig('data', 'templates').map { |t| t['slug'] }
      expect(slugs).to eq([ 'wedding-classic' ])
    end

    it 'serves the catalog without any session cookie' do
      create(:template, :published, slug: 'open-catalog')

      get '/api/v1/guest/templates', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns the document body on a published template detail' do
      create(:template, :published, :with_document, slug: 'render-me')

      get '/api/v1/guest/templates/render-me', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'template', 'document', 'document')).to be_present
    end
  end
end
