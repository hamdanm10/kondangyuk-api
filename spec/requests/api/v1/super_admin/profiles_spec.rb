require 'swagger_helper'

RSpec.describe 'API V1 Profile', type: :request do
  path '/api/v1/super_admin/profile' do
    get 'Get own profile' do
      tags        'Super Admin | Profiles'
      produces    'application/json'
      description 'Returns the authenticated user profile. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'profile returned' do
        let(:user) { create(:user, :super_admin) }
        before { login_as(user) }

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

        run_test!
      end

      response '401', 'not authenticated' do
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'fail' },
                 data: { type: :object }
               }

        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    patch 'Update own account' do
      tags        'Super Admin | Profiles'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates the authenticated user own account (full_name, email and optionally ' \
                  'password). Changing the password requires the correct current_password and a ' \
                  'matching password_confirmation. role and is_active cannot be changed here. ' \
                  'Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: 'Accept-Language', in: :header, type: :string, required: false,
                description: 'Response language — "id" or "en" (default: en when absent/unsupported)'

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          profile: {
            type: :object,
            properties: {
              full_name:             { type: :string, example: 'Updated Name' },
              email:                 { type: :string, example: 'updated@kondangyuk.test' },
              password:              { type: :string, example: 'NewPassword12345!' },
              password_confirmation: { type: :string, example: 'NewPassword12345!' },
              current_password:      { type: :string, example: 'Password12345!' }
            }
          }
        }
      }

      response '200', 'account updated' do
        let(:user) { create(:user, :super_admin, password: 'Password12345!') }
        let(:body) do
          { profile: { full_name: 'Updated Name', email: 'updated@kondangyuk.test',
                       password: 'NewPassword12345!', password_confirmation: 'NewPassword12345!',
                       current_password: 'Password12345!' } }
        end
        before { login_as(user) }

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
                         role:      { type: :string, example: 'super_admin' },
                         is_active: { type: :boolean, example: true }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)['data']['user']
          expect(data['full_name']).to eq('Updated Name')
          expect(data['email']).to eq('updated@kondangyuk.test')
          expect(user.reload.authenticate('NewPassword12345!')).to be_truthy
        end
      end

      response '422', 'validation failure — wrong current_password' do
        let(:user) { create(:user, :super_admin, password: 'Password12345!') }
        let(:body) do
          { profile: { password: 'NewPassword12345!', password_confirmation: 'NewPassword12345!',
                       current_password: 'WrongPassword!' } }
        end
        before { login_as(user) }

        schema '$ref' => '#/components/schemas/JSendFail'

        run_test! do |response|
          expect(JSON.parse(response.body)['data']).to have_key('current_password')
        end
      end

      response '422', 'validation failure — password_confirmation mismatch' do
        let(:user) { create(:user, :super_admin, password: 'Password12345!') }
        let(:body) do
          { profile: { password: 'NewPassword12345!', password_confirmation: 'Mismatch12345!',
                       current_password: 'Password12345!' } }
        end
        before { login_as(user) }

        schema '$ref' => '#/components/schemas/JSendFail'

        run_test! do |response|
          expect(JSON.parse(response.body)['data']).to have_key('password_confirmation')
        end
      end

      response '422', 'validation failure — invalid email' do
        let(:user) { create(:user, :super_admin) }
        let(:body) { { profile: { email: 'not-an-email' } } }
        before { login_as(user) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:body) { { profile: { full_name: 'Updated Name' } } }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:body) { { profile: { full_name: 'Updated Name' } } }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
