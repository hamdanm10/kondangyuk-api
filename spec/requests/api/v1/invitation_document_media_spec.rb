require 'swagger_helper'

RSpec.describe 'API V1 Invitation Document Media', type: :request do
  let(:image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.png'), 'image/png') }
  let(:text)  { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.png'), 'text/plain') }

  path '/api/v1/invitations/{invitation_id}/document/media' do
    parameter name: :invitation_id, in: :path, type: :string, required: true,
              description: 'Invitation ID or slug'

    get 'List document media' do
      tags 'Admin | Media'
      produces 'application/json'
      description 'Lists media attached to an invitation document (proxy URLs). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'media returned' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'invitation or document not found' do
        let(:admin) { create(:user) }
        let(:invitation_id) { 0 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    post 'Upload document media' do
      tags 'Admin | Media'
      consumes 'multipart/form-data'
      produces 'application/json'
      description 'Uploads a media file (image/audio/video) to an invitation document and returns its ' \
                  'stable proxy URL. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :file, in: :formData, type: :file, required: true

      response '201', 'media uploaded' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:file) { image }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'unsupported media type' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:file) { text }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        let(:file) { image }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end

  path '/api/v1/invitations/{invitation_id}/document/media/{id}' do
    parameter name: :invitation_id, in: :path, type: :string, required: true
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Media (attachment) ID'

    delete 'Delete document media' do
      tags 'Admin | Media'
      produces 'application/json'
      description 'Permanently deletes (purges) a media attachment by ID — hard delete. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'media deleted' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:id) { MediaRepository.new.attach(invitation.invitation_document, image).id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'media not found' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:id) { 0 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        let(:id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
