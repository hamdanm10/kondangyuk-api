require 'swagger_helper'

RSpec.describe 'API V1 Public Templates', type: :request do
  path '/api/v1/public/templates' do
    get 'List published templates (public catalog)' do
      tags        'Public | Templates'
      produces    'application/json'
      description 'Public template catalog — returns published templates (those with a published_at) ' \
                  'with pagination, optionally filtered by theme or tier. No authentication required. ' \
                  'Unpublished/draft templates are excluded.'

      parameter name: :page,  in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Items per page (default: 10, max: 100)'
      parameter name: :theme_id, in: :query, type: :integer, required: false,
                description: 'Filter by theme id (templates having that theme)'
      parameter name: :tier_id, in: :query, type: :integer, required: false,
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

  describe 'visibility' do
    it 'lists only published templates and excludes drafts' do
      create(:template, :published, slug: 'live-one', name: 'Live One')
      create(:template, slug: 'draft-one', name: 'Draft One')

      get '/api/v1/public/templates', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      slugs = JSON.parse(response.body).dig('data', 'templates').map { |t| t['slug'] }
      expect(slugs).to include('live-one')
      expect(slugs).not_to include('draft-one')
    end

    it 'serves the catalog without any session cookie' do
      create(:template, :published, slug: 'open-catalog')

      get '/api/v1/public/templates', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
    end
  end
end
