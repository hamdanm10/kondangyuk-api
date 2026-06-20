require 'swagger_helper'

RSpec.describe 'API V1 Public Invitations', type: :request do
  path '/api/v1/guest/invitations/{slug}' do
    get 'Show published invitation (public customer page)' do
      tags 'Public | Invitations'
      produces 'application/json'
      description 'Public customer page — returns a published, non-expired invitation by slug together ' \
                  'with its document (meta + MDX) and thumbnail URL. No authentication required. ' \
                  'Unpublished or expired invitations return 404.'

      parameter name: :slug, in: :path, type: :string, required: true, description: 'Invitation slug'

      response '200', 'invitation returned' do
        let(:slug) { create(:invitation, :published, :with_document, slug: 'andi-and-budi').slug }
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     invitation: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         description:  { type: :string, nullable: true },
                         published_at: { type: :string, format: 'date-time', nullable: true },
                         expires_at:   { type: :string, format: 'date-time', nullable: true },
                         thumbnail_url: { type: :string, nullable: true },
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

      response '404', 'unpublished invitation' do
        let(:slug) { create(:invitation, :with_document, slug: 'draft-one').slug }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'expired invitation' do
        let(:slug) { create(:invitation, :expired, :with_document, slug: 'expired-one').slug }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  describe 'no authentication required' do
    it 'serves the page without any session cookie' do
      invitation = create(:invitation, :published, :with_document, slug: 'public-open')

      get '/api/v1/guest/invitations/public-open', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.dig('data', 'invitation', 'slug')).to eq('public-open')
      expect(body.dig('data', 'invitation', 'document', 'document')).to be_present
      expect(invitation.published?).to be(true)
    end
  end
end
