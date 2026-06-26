require 'swagger_helper'

RSpec.describe 'API V1 Invitations', type: :request do
  path '/api/v1/super_admin/invitations/{id}' do
    get 'Show invitation' do
      tags 'Super Admin | Invitations'
      produces 'application/json'
      description 'Returns a single invitation by ID or slug. Invitations are created, updated and ' \
                  'deleted through their order; this read-only detail stays available. Accessible ' \
                  'by super_admin only.'
      security [ cookieAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true, description: 'Invitation ID or slug'

      response '200', 'invitation returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:invitation) { create(:invitation) }
        let(:id) { invitation.id }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'invitation', 'id')).to eq(invitation.id)
        end
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
end
