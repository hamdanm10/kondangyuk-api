require 'swagger_helper'

RSpec.describe 'API V1 Invitation Documents', type: :request do
  path '/api/v1/super_admin/invitations/{invitation_id}/document' do
    parameter name: :invitation_id, in: :path, type: :string, required: true,
              description: 'Invitation ID or slug'

    get 'Show invitation document' do
      tags 'Super Admin | Invitation Documents'
      produces 'application/json'
      description 'Returns the invitation document (meta + MDX snapshot). Accessible by super_admin only.'
      security [ cookieAuth: [] ]

      response '200', 'document returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'invitation or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation_id) { 0 }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:invitation_id) { 1 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    patch 'Update invitation document' do
      tags 'Super Admin | Invitation Documents'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates the invitation document (meta + MDX). Accessible by super_admin only.'
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
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:body) { { invitation_document: { meta: { title: 'X' }, document: '# Updated' } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        let(:body) { { invitation_document: { document: '' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'invitation or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation_id) { 0 }
        let(:body) { { invitation_document: { document: '# x' } } }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        let(:body) { { invitation_document: { document: '# x' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:invitation_id) { 1 }
        let(:body) { { invitation_document: { document: '# x' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete invitation document' do
      tags 'Super Admin | Invitation Documents'
      produces 'application/json'
      description 'Permanently deletes an invitation document (hard delete). The invitation_documents ' \
                  'table has no deleted_at column. Accessible by super_admin only.'
      security [ cookieAuth: [] ]

      response '200', 'document deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation, :with_document) }
        let(:invitation_id) { invitation.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'invitation or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation_id) { 0 }
        before { login_as(super_admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:invitation_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:invitation_id) { 1 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
