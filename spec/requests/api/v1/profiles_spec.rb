require 'swagger_helper'

RSpec.describe 'API V1 Profile', type: :request do
  path '/api/v1/profile' do
    get 'Get own profile' do
      tags        'Admin'
      produces    'application/json'
      description 'Returns the authenticated user profile. Accessible by admin and super_admin.'
      security    [ cookieAuth: [] ]

      response '200', 'profile returned' do
        let(:user) { create(:user) }
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
    end
  end
end
