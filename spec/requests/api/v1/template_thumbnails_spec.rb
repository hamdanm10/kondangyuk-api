require 'swagger_helper'

RSpec.describe 'API V1 Template Thumbnail', type: :request do
  let(:image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.png'), 'image/png') }
  let(:text)  { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.png'), 'text/plain') }

  path '/api/v1/templates/{template_id}/thumbnail' do
    parameter name: :template_id, in: :path, type: :string, required: true, description: 'Template ID or slug'

    get 'Show thumbnail' do
      tags 'Admin | Thumbnails'
      produces 'application/json'
      description 'Returns the template thumbnail proxy URL (or null). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'thumbnail returned' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:template_id) { template.id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '404', 'template not found' do
        let(:admin) { create(:user) }
        let(:template_id) { 0 }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    put 'Upload thumbnail' do
      tags 'Admin | Thumbnails'
      consumes 'multipart/form-data'
      produces 'application/json'
      description 'Uploads/replaces the template thumbnail (image only). Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]
      parameter name: :thumbnail, in: :formData, type: :file, required: true

      response '200', 'thumbnail uploaded' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:template_id) { template.id }
        let(:thumbnail) { image }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '422', 'not an image' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:template_id) { template.id }
        let(:thumbnail) { text }
        before { login_as(admin) }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }
        let(:thumbnail) { image }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end

    delete 'Remove thumbnail' do
      tags 'Admin | Thumbnails'
      produces 'application/json'
      description 'Removes (purges) the template thumbnail — hard delete. Accessible by admin or super_admin.'
      security [ cookieAuth: [] ]

      response '200', 'thumbnail removed' do
        let(:admin) { create(:user) }
        let(:template) { create(:template) }
        let(:template_id) { template.id }
        before { login_as(admin) }
        schema type: :object, properties: { status: { type: :string }, data: { type: :object } }
        run_test!
      end

      response '401', 'not authenticated' do
        let(:template_id) { 1 }
        schema '$ref' => '#/components/schemas/JSendFail'
        run_test!
      end
    end
  end
end
