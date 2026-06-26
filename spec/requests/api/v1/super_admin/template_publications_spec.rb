require 'swagger_helper'

RSpec.describe 'API V1 Template Publications', type: :request do
  path '/api/v1/super_admin/templates/{template_id}/publication' do
    parameter name: :template_id, in: :path, type: :integer, required: true, description: 'Template ID'

    post 'Publish template' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Publishes a template by setting published_at to the current time. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'template published' do
        let(:super_admin)  { create(:user, :super_admin) }
        let(:template)     { create(:template) }
        let(:template_id)  { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     template: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         published_at: { type: :string, format: 'date-time' }
                       }
                     }
                   }
                 }
               }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'template', 'published_at')).to be_present
        end
      end

      response '404', 'template not found' do
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

    delete 'Unpublish template' do
      tags        'Super Admin | Templates'
      produces    'application/json'
      description 'Unpublishes a template by clearing published_at. Accessible by super_admin only.'
      security    [ cookieAuth: [] ]

      response '200', 'template unpublished' do
        let(:super_admin)  { create(:user, :super_admin) }
        let(:template)     { create(:template, :published) }
        let(:template_id)  { template.id }
        before { login_as(super_admin) }

        schema type: :object,
               properties: {
                 status: { type: :string, example: 'success' },
                 data: {
                   type: :object,
                   properties: {
                     template: {
                       type: :object,
                       properties: {
                         id:           { type: :integer },
                         slug:         { type: :string },
                         name:         { type: :string },
                         published_at: { type: :string, nullable: true }
                       }
                     }
                   }
                 }
               }
        run_test! do |response|
          expect(JSON.parse(response.body).dig('data', 'template', 'published_at')).to be_nil
        end
      end

      response '404', 'template not found' do
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
