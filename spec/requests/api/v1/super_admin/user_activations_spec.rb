require 'swagger_helper'

RSpec.describe 'API V1 User Activations', type: :request do
  path '/api/v1/super_admin/users/{user_id}/activation' do
    parameter name: :user_id, in: :path, type: :integer, required: true,
              description: 'User ID'

    post 'Activate user' do
      tags        'Super Admin | Users'
      produces    'application/json'
      description 'Activates a user (sets is_active to true). Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'user activated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:target)      { create(:user, :inactive) }
        let(:user_id)     { target.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     user: {
                       type: :object,
                       properties: {
                         id:        { type: :integer },
                         full_name: { type: :string },
                         email:     { type: :string },
                         role:      { type: :string, example: 'admin' },
                         is_active: { type: :boolean, example: true }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'user', 'is_active')).to be(true)
          expect(target.reload.is_active).to be(true)
        end
      end

      response '422', 'super_admin cannot be activated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:target)      { create(:user, :super_admin, :inactive) }
        let(:user_id)     { target.id }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'role')).to be_present
        end
      end

      response '404', 'user not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:user_id)     { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:user_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin)   { create(:user) }
        let(:user_id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Deactivate user' do
      tags        'Super Admin | Users'
      produces    'application/json'
      description 'Deactivates a user (sets is_active to false) and signs out any active ' \
                  'sessions. The user cannot log in while deactivated. Super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'user deactivated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:target)      { create(:user) }
        let(:user_id)     { target.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     user: {
                       type: :object,
                       properties: {
                         id:        { type: :integer },
                         full_name: { type: :string },
                         email:     { type: :string },
                         role:      { type: :string, example: 'admin' },
                         is_active: { type: :boolean, example: false }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'user', 'is_active')).to be(false)
          expect(target.reload.is_active).to be(false)
        end
      end

      response '422', 'super_admin cannot be deactivated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:target)      { create(:user, :super_admin) }
        let(:user_id)     { target.id }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'role')).to be_present
        end
      end

      response '404', 'user not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:user_id)     { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:user_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin)   { create(:user) }
        let(:user_id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
