require 'swagger_helper'

RSpec.describe 'API V1 Invitation Publications', type: :request do
  path '/api/v1/super_admin/invitations/{invitation_id}/publication' do
    parameter name: :invitation_id, in: :path, type: :integer, required: true, description: 'Invitation ID'

    post 'Publish invitation' do
      tags        'Super Admin | Invitations'
      produces    'application/json'
      description 'Publishes an invitation by setting published_at to the current time, making it ' \
                  'visible on its public page. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'invitation published' do
        let(:super_admin)    { create(:user, :super_admin) }
        let(:invitation)     { create(:invitation) }
        let(:invitation_id)  { invitation.id }
        before { login_as(super_admin) }

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
                         published_at: { type: :string, format: 'date-time' },
                         expires_at:   { type: :string, nullable: true }
                       }
                     }
                   }
                 }
               }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'invitation', 'published_at')).to be_present
        end
      end

      response '404', 'invitation not found' do
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

    delete 'Unpublish invitation' do
      tags        'Super Admin | Invitations'
      produces    'application/json'
      description 'Unpublishes an invitation by clearing published_at. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'invitation unpublished' do
        let(:super_admin)    { create(:user, :super_admin) }
        let(:invitation)     { create(:invitation, :published) }
        let(:invitation_id)  { invitation.id }
        before { login_as(super_admin) }

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
                         published_at: { type: :string, nullable: true },
                         expires_at:   { type: :string, nullable: true }
                       }
                     }
                   }
                 }
               }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'invitation', 'published_at')).to be_nil
        end
      end

      response '404', 'invitation not found' do
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
