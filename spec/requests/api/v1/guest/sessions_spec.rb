require 'swagger_helper'

RSpec.describe 'API V1 Sessions', type: :request do
  path '/api/v1/guest/session' do
    post 'Login' do
      tags        'Public | Sessions'
      consumes    'application/json'
      produces    'application/json'
      description 'Authenticates user and sets httpOnly session cookie. Rate limited to 10 requests/minute per IP.'

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              email:    { type: :string, example: 'admin@kondangyuk.test' },
              password: { type: :string, example: 'Password12345!' }
            },
            required: %w[email password]
          }
        }
      }

      response '201', 'login successful' do
        let(:user) { create(:user) }
        let(:body) { { session: { email: user.email, password: 'Password12345!' } } }

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
                         email: { type: :string }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '422', 'invalid credentials' do
        let(:body) { { session: { email: 'wrong@example.com', password: 'wrongpassword' } } }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'fail' },
                 data: { type: :object }
               }

        run_test!
      end

      response '422', 'account deactivated' do
        let(:user) { create(:user, :inactive) }
        let(:body) { { session: { email: user.email, password: 'Password12345!' } } }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'fail' },
                 data: { type: :object }
               }

        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'account')).to be_present
        end
      end
    end

    delete 'Logout' do
      tags        'Public | Sessions'
      produces    'application/json'
      description 'Destroys the current session and clears the session cookie.'
      security    [ cookieAuth: [] ]

      response '204', 'logout successful' do
        let(:user) { create(:user) }
        before { login_as(user) }

        run_test!
      end
    end
  end
end
