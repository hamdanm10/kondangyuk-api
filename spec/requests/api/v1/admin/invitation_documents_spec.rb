require 'swagger_helper'

RSpec.describe 'API V1 Invitation Documents', type: :request do
  path '/api/v1/admin/invitations/{invitation_id}/document' do
    parameter name: :invitation_id, in: :path, type: :string, required: true,
              description: 'Invitation ID or slug'

    get 'Show invitation document' do
      tags 'Admin | Invitation Documents'
      produces 'application/json'
      description 'Returns the invitation document (meta + MDX snapshot). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'document returned' do
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

    patch 'Update invitation document' do
      tags 'Admin | Invitation Documents'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates the invitation document (meta + MDX). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          invitation_document: {
            type: :object,
            properties: {
              meta:     { type: :object },
              document: { type: :string }
            },
            required: %w[document]
          }
        }
      }

      response '200', 'document updated' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:body) { { invitation_document: { meta: { title: 'X' }, document: '# Updated' } } }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'validation failed' do
        let(:admin) { create(:user) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:body) { { invitation_document: { document: '' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'invitation or document not found' do
        let(:admin) { create(:user) }
        let(:invitation_id) { 0 }
        let(:body) { { invitation_document: { document: '# x' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        let(:body) { { invitation_document: { document: '# x' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete invitation document' do
      tags 'Admin | Invitation Documents'
      produces 'application/json'
      description 'Permanently deletes an invitation document (hard delete). The invitation_documents ' \
                  'table has no deleted_at column. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'document deleted' do
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
  end
end
