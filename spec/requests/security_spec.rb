require 'rails_helper'

RSpec.describe 'Security: BotGuard + anti-indexing', type: :request do
  let(:published) { create(:invitation, :published, :with_document, slug: 'guard-me') }
  let(:public_path) { "/api/v1/guest/invitations/#{published.slug}" }
  let(:json) { { 'ACCEPT' => 'application/json' } }

  describe 'bot blocking on protected paths' do
    it 'blocks a known AI/scraper User-Agent with 403' do
      get public_path, headers: json.merge('User-Agent' => 'GPTBot/1.1 (+https://openai.com/gptbot)')

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['status']).to eq('fail')
    end

    it 'blocks generic crawler/spider User-Agents' do
      get public_path, headers: json.merge('User-Agent' => 'SomeRandomCrawler/2.0')

      expect(response).to have_http_status(:forbidden)
    end

    it 'allows a normal browser User-Agent' do
      get public_path, headers: json.merge('User-Agent' => 'Mozilla/5.0 (Macintosh) Safari/605')

      expect(response).to have_http_status(:ok)
    end

    it 'does not touch non-protected paths even for a bot UA' do
      get '/up', headers: { 'User-Agent' => 'GPTBot' }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'anti-indexing header' do
    it 'sets X-Robots-Tag noindex on public responses' do
      get public_path, headers: json.merge('User-Agent' => 'Mozilla/5.0')

      expect(response.headers['X-Robots-Tag']).to include('noindex')
    end

    it 'sets X-Robots-Tag noindex on admin API responses too' do
      login_as(create(:user))
      get '/api/v1/admin/orders', headers: json

      expect(response.headers['X-Robots-Tag']).to include('noindex')
    end
  end

  describe 'per-IP rate limiting on protected paths' do
    before { allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new) }

    it 'returns 429 once the per-IP limit is exceeded' do
      limit = Rails.application.config.x.bot_guard.rate_limit
      headers = json.merge('User-Agent' => 'Mozilla/5.0')

      limit.times { get public_path, headers: headers }
      expect(response).to have_http_status(:ok)

      get public_path, headers: headers
      expect(response).to have_http_status(:too_many_requests)
      expect(response.headers['Retry-After']).to be_present
    end
  end
end
