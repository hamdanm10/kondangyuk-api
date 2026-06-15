require 'swagger_helper'

RSpec.describe 'API V1 Template Documents', type: :request do
  path '/api/v1/templates/{template_id}/document' do
    parameter name: :template_id, in: :path, type: :string, required: true,
              description: 'Template ID or slug'

    get 'Show template document' do
      tags        'Super Admin | Template Documents'
      produces    'application/json'
      description 'Returns the document (frontmatter meta + raw MDX) for a template, looked up by ' \
                  'template ID or slug. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'document returned' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template, :with_document) }
        let(:template_id) { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     document: {
                       type: :object,
                       properties: {
                         id:          { type: :integer },
                         template_id: { type: :integer },
                         meta:        { type: :object },
                         document:    { type: :string }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'template or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template_id) { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:template_id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    patch 'Update template document' do
      tags        'Super Admin | Template Documents'
      consumes    'application/json'
      produces    'application/json'
      description 'Updates the document (meta + MDX) for a template, looked up by template ID or slug. ' \
                  'Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          template_document: {
            type: :object,
            properties: {
              meta:     { type: :object, example: { title: 'Updated' } },
              document: { type: :string, example: "---\ntitle: Updated\n---\n# Updated" }
            },
            required: %w[document]
          }
        }
      }

      response '200', 'document updated' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template, :with_document) }
        let(:template_id) { template.id }
        let(:body) { { template_document: { meta: { title: 'Updated' }, document: "# Updated" } } }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     document: {
                       type: :object,
                       properties: {
                         id:          { type: :integer },
                         template_id: { type: :integer },
                         meta:        { type: :object },
                         document:    { type: :string }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '422', 'validation failed' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template, :with_document) }
        let(:template_id) { template.id }
        let(:body) { { template_document: { document: '' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '404', 'template or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template_id) { 0 }
        let(:body) { { template_document: { document: '# x' } } }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }
        let(:body) { { template_document: { document: '# x' } } }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:template_id) { 1 }
        let(:body) { { template_document: { document: '# x' } } }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Delete template document' do
      tags        'Super Admin | Template Documents'
      produces    'application/json'
      description 'Permanently deletes a template document (hard delete). The template_documents table ' \
                  'has no deleted_at column. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'document deleted' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template) { create(:template, :with_document) }
        let(:template_id) { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data:   { type: :object }
               }

        run_test!
      end

      response '404', 'template or document not found' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:template_id) { 0 }
        before { login_as(super_admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '403', 'forbidden — admin role cannot access' do
        let(:admin) { create(:user) }
        let(:template_id) { 1 }
        before { login_as(admin) }

        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
