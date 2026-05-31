require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Kondangyuk API',
        version: 'v1',
        description: 'API documentation for Kondangyuk'
      },
      components: {
        securitySchemes: {
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: :session_token
          }
        },
        schemas: {
          JSendSuccess: {
            type: :object,
            properties: {
              status: { type: :string, example: 'success' },
              data: { type: :object }
            }
          },
          JSendFail: {
            type: :object,
            properties: {
              status: { type: :string, example: 'fail' },
              data: { type: :object }
            }
          }
        }
      },
      tags: [
        {
          name: 'Public | Sessions',
          description: 'Authentication — login and logout. No authentication required.'
        },
        {
          name: 'Admin | Profiles',
          description: 'Authenticated user profile. Accessible by **admin** and **super_admin** roles.'
        },
        {
          name: 'Super Admin | Users',
          description: 'Admin user management. Accessible by **super_admin** role only.'
        },
        {
          name: 'Super Admin | Themes',
          description: 'Digital invitation theme management. Accessible by **super_admin** role only.'
        }
      ],
      servers: [
        { url: 'http://localhost:3000', description: 'Development' }
      ]
    }
  }

  config.openapi_format = :yaml
end
