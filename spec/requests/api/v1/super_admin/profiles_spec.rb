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
                         id:    { type: :integer },
                         email: { type: :string },
                         role:  { type: :string, example: 'admin' }
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
  end
end
