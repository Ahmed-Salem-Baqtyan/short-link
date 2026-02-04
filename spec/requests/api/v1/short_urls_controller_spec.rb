require 'rails_helper'

RSpec.describe('Api::V1::ShortUrlsController', type: :request) do
  include Requests::JsonHelpers

  let(:user) { create(:user) }
  let(:user_session) { create(:session, user: user) }
  let(:api_access_token) { Rails.application.credentials.api_access_token }

  let(:valid_headers) do
    {
      'API-ACCESS-TOKEN' => api_access_token,
      'Authorization' => "Bearer #{user_session.token}",
      'Content-Type' => 'application/json'
    }
  end

  let(:invalid_api_token_headers) do
    {
      'API-ACCESS-TOKEN' => 'invalid_token',
      'Authorization' => "Bearer #{user_session.token}",
      'Content-Type' => 'application/json'
    }
  end

  let(:invalid_session_token_headers) do
    {
      'API-ACCESS-TOKEN' => api_access_token,
      'Authorization' => 'Bearer invalid_session_token',
      'Content-Type' => 'application/json'
    }
  end

  let(:missing_api_token_headers) do
    {
      'Authorization' => "Bearer #{user_session.token}",
      'Content-Type' => 'application/json'
    }
  end

  let(:missing_session_token_headers) do
    {
      'API-ACCESS-TOKEN' => api_access_token,
      'Content-Type' => 'application/json'
    }
  end

  describe 'POST /api/v1/short_urls/encode' do
    let(:valid_url) { 'https://example.com/test-page' }
    let(:valid_params) { { short_url: { url: valid_url } } }

    context 'with valid authentication and parameters' do
      it 'creates a new short URL and returns encoded URL' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
        expect(json_response[:message]).to(eq('Link encoded successfully'))
        expect(data_response[:encoded_url]).to(be_present)
        expect(data_response[:encoded_url]).to(include('/api/v1/short_urls/decode/'))
      end

      it 'persists the short URL to the database' do
        expect do
          post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
        end.to(change(ShortUrl, :count).by(1))
      end

      it 'associates the short URL with the current user' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)

        short_url = ShortUrl.last
        expect(short_url.user_id).to(eq(user.id))
        expect(short_url.url).to(eq(valid_url))
      end

      it 'generates a unique code for the short URL' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)

        short_url = ShortUrl.last
        expect(short_url.code).to(be_present)
        expect(short_url.code).to(match(/\A[a-zA-Z0-9]+\z/))
      end

      it 'allows encoding the same URL multiple times' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
        first_code = ShortUrl.last.code

        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
        second_code = ShortUrl.last.code

        expect(first_code).not_to(eq(second_code))
      end
    end

    context 'with various valid URL formats' do
      it 'accepts URLs with query parameters' do
        params = { short_url: { url: 'https://example.com/page?param=value&other=test' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
      end

      it 'accepts URLs with fragments' do
        params = { short_url: { url: 'https://example.com/page#section' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
      end

      it 'accepts URLs with ports' do
        params = { short_url: { url: 'https://example.com:8080/api/endpoint' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
      end

      it 'accepts URLs with paths' do
        params = { short_url: { url: 'https://example.com/api/v1/users/123' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
      end
    end

    context 'with invalid URL formats' do
      it 'rejects URLs without HTTPS protocol' do
        params = { short_url: { url: 'http://example.com' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
        expect(error_response).to(include('must use HTTPS'))
      end

      it 'rejects URLs without protocol' do
        params = { short_url: { url: 'example.com' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
      end

      it 'rejects localhost URLs' do
        params = { short_url: { url: 'https://localhost/test' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
        expect(error_response).to(include('localhost'))
      end

      it 'rejects private IP addresses' do
        params = { short_url: { url: 'https://192.168.1.1/test' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
        expect(error_response).to(include('private'))
      end

      it 'rejects loopback IP addresses' do
        params = { short_url: { url: 'https://127.0.0.1/test' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
      end

      it 'rejects invalid URLs' do
        params = { short_url: { url: 'not-a-valid-url' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(json_response[:success]).to(be(false))
      end
    end

    context 'with missing or invalid parameters' do
      it 'returns error when URL is missing' do
        params = { short_url: {} }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:bad_request))
        expect(json_response[:success]).to(be(false))
      end

      it 'returns error when URL is blank' do
        params = { short_url: { url: '' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:bad_request))
        expect(json_response[:success]).to(be(false))
      end

      it 'returns error when URL is nil' do
        params = { short_url: { url: nil } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:bad_request))
        expect(json_response[:success]).to(be(false))
      end

      it 'returns error when params are completely empty' do
        post('/api/v1/short_urls/encode', params: {}.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:bad_request))
        expect(json_response[:success]).to(be(false))
      end

      it 'strips whitespace from URLs' do
        params = { short_url: { url: '  https://example.com/test  ' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        short_url = ShortUrl.last
        expect(short_url.url).to(eq('https://example.com/test'))
      end
    end

    context 'with authentication issues' do
      it 'returns 401 when API access token is missing' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: missing_api_token_headers)

        expect(response).to(have_http_status(:unauthorized))
      end

      it 'returns 401 when API access token is invalid' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: invalid_api_token_headers)

        expect(response).to(have_http_status(:unauthorized))
      end

      it 'returns 401 when session token is missing' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: missing_session_token_headers)

        expect(response).to(have_http_status(:unauthorized))
      end

      it 'returns 401 when session token is invalid' do
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: invalid_session_token_headers)

        expect(response).to(have_http_status(:unauthorized))
      end
    end

    context 'with rate limiting' do
      it 'enforces per-user URL creation limit' do
        # Set limit to 2 and create 2 URLs to reach the limit
        stub_const('ShortUrl::SHORT_LINKS_LIMIT', 2)

        2.times do
          create(:short_url, user: user)
        end

        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(error_response).to(include('limit'))
      end

      it 'allows creating URLs up to the limit' do
        stub_const('ShortUrl::SHORT_LINKS_LIMIT', 3)

        # Create 2 URLs
        2.times do
          create(:short_url, user: user)
        end

        # Creating the 3rd URL (at limit) should succeed
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(user.short_urls.count).to(eq(3))
      end
    end

    context 'with edge cases' do
      it 'handles very long URLs' do
        long_url = "https://example.com/#{'a' * 2000}"
        params = { short_url: { url: long_url } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:ok))
      end

      it 'handles URLs with special characters' do
        params = { short_url: { url: 'https://example.com/test?query=hello%20world&special=!@#$%^&*()' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
      end

      it 'handles URLs with unicode characters' do
        params = { short_url: { url: 'https://example.com/page?q=こんにちは' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)

        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end
  end

  describe 'GET /api/v1/short_urls/decode/:code' do
    let!(:short_url) { create(:short_url, user: user, url: 'https://example.com/original') }

    context 'with valid code and authentication' do
      it 'returns the original URL for a valid code' do
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
        expect(json_response[:message]).to(eq('Link decoded successfully'))
        expect(data_response[:decoded_url]).to(eq('https://example.com/original'))
      end

      it 'decodes URL case-sensitively' do
        short_url.update(code: 'AbC123')

        get('/api/v1/short_urls/decode/AbC123', headers: valid_headers)
        expect(response).to(have_http_status(:ok))

        get('/api/v1/short_urls/decode/abc123', headers: valid_headers)
        expect(response).to(have_http_status(:not_found))
      end

      it 'allows decoding the same URL multiple times' do
        3.times do
          get("/api/v1/short_urls/decode/#{short_url.code}", headers: valid_headers)
          expect(response).to(have_http_status(:ok))
        end
      end
    end

    context 'without authentication (public access)' do
      let(:public_headers) do
        {
          'API-ACCESS-TOKEN' => api_access_token,
          'Content-Type' => 'application/json'
        }
      end

      it 'allows decoding without session token' do
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)

        expect(response).to(have_http_status(:ok))
        expect(json_response[:success]).to(be(true))
        expect(data_response[:decoded_url]).to(eq('https://example.com/original'))
      end

      it 'works with only API access token' do
        headers = { 'API-ACCESS-TOKEN' => api_access_token }
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: headers)

        expect(response).to(have_http_status(:ok))
      end

      it 'allows anyone to decode any short URL' do
        other_user = create(:user, email_address: 'other@example.com')
        other_short_url = create(:short_url, user: other_user, url: 'https://example.com/public')

        get("/api/v1/short_urls/decode/#{other_short_url.code}", headers: public_headers)

        expect(response).to(have_http_status(:ok))
        expect(data_response[:decoded_url]).to(eq('https://example.com/public'))
      end
    end

    context 'with non-existent codes' do
      it 'returns 404 for non-existent code with user-friendly message' do
        get('/api/v1/short_urls/decode/NONEXISTENT', headers: valid_headers)

        expect(response).to(have_http_status(:not_found))
        expect(json_response[:success]).to(be(false))
        expect(error_response).to(eq("This is a 404 error, which means you've entered an invalid URL"))
      end

      it 'returns 404 for empty code' do
        get('/api/v1/short_urls/decode/', headers: valid_headers)

        expect(response).to(have_http_status(:not_found))
      end

      it 'returns 404 for malformed codes' do
        get('/api/v1/short_urls/decode/invalid@code!', headers: valid_headers)

        expect(response).to(have_http_status(:not_found))
      end

      it 'works without authentication for non-existent codes' do
        public_headers = { 'API-ACCESS-TOKEN' => api_access_token }
        get('/api/v1/short_urls/decode/NONEXISTENT', headers: public_headers)

        expect(response).to(have_http_status(:not_found))
      end
    end

    context 'with API authentication' do
      it 'returns 401 when API access token is missing' do
        headers = { 'Content-Type' => 'application/json' }
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: headers)

        expect(response).to(have_http_status(:unauthorized))
      end

      it 'returns 401 when API access token is invalid' do
        headers = {
          'API-ACCESS-TOKEN' => 'invalid_token',
          'Content-Type' => 'application/json'
        }
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: headers)

        expect(response).to(have_http_status(:unauthorized))
      end

      it 'does NOT require session token (public endpoint)' do
        headers = {
          'API-ACCESS-TOKEN' => api_access_token,
          'Content-Type' => 'application/json'
        }
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: headers)

        expect(response).to(have_http_status(:ok))
      end

      it 'ignores invalid session tokens (no authentication required)' do
        headers = {
          'API-ACCESS-TOKEN' => api_access_token,
          'Authorization' => 'Bearer invalid_token',
          'Content-Type' => 'application/json'
        }
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: headers)

        expect(response).to(have_http_status(:ok))
      end
    end

    context 'with special code formats' do
      it 'handles codes with numbers and letters' do
        short_url.update(code: 'aBc123XyZ')
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: valid_headers)

        expect(response).to(have_http_status(:ok))
      end

      it 'handles very short codes' do
        short_url.update(code: 'a')
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: valid_headers)

        expect(response).to(have_http_status(:ok))
      end

      it 'handles longer codes' do
        short_url.update(code: 'A' * 50)
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: valid_headers)

        expect(response).to(have_http_status(:ok))
      end
    end

    context 'with edge cases' do
      it 'handles codes with trailing period (routing edge case)' do
        # This tests the route constraint fix for periods
        get("/api/v1/short_urls/decode/#{short_url.code}.", headers: valid_headers)

        # Should be caught by the catch-all route and return 404
        expect(response).to(have_http_status(:not_found))
      end

      it 'decodes URLs that were recently created' do
        new_url_params = { short_url: { url: 'https://example.com/new' } }
        post('/api/v1/short_urls/encode', params: new_url_params.to_json, headers: valid_headers)

        new_code = ShortUrl.last.code
        get("/api/v1/short_urls/decode/#{new_code}", headers: valid_headers)

        expect(response).to(have_http_status(:ok))
        expect(data_response[:decoded_url]).to(eq('https://example.com/new'))
      end
    end
  end

  describe 'Integration: Encode and Decode workflow' do
    it 'successfully encodes and then decodes a URL' do
      # Encode
      encode_params = { short_url: { url: 'https://codesubmit.io/library/react' } }
      post('/api/v1/short_urls/encode', params: encode_params.to_json, headers: valid_headers)

      expect(response).to(have_http_status(:ok))
      encoded_url = data_response[:encoded_url]
      code = encoded_url.split('/').last

      # Decode
      get("/api/v1/short_urls/decode/#{code}", headers: valid_headers)

      expect(response).to(have_http_status(:ok))
      expect(data_response[:decoded_url]).to(eq('https://codesubmit.io/library/react'))
    end

    it 'persists URLs across application restarts' do
      encode_params = { short_url: { url: 'https://example.com/persistent' } }
      post('/api/v1/short_urls/encode', params: encode_params.to_json, headers: valid_headers)

      code = ShortUrl.last.code

      Current.reset

      get("/api/v1/short_urls/decode/#{code}", headers: valid_headers)

      expect(response).to(have_http_status(:ok))
      expect(data_response[:decoded_url]).to(eq('https://example.com/persistent'))
    end

    it 'handles multiple URLs being encoded and decoded' do
      urls = [
        'https://example.com/one',
        'https://example.com/two',
        'https://example.com/three'
      ]

      codes = []
      urls.each do |url|
        params = { short_url: { url: url } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        codes << ShortUrl.last.code
      end

      codes.each_with_index do |code, index|
        get("/api/v1/short_urls/decode/#{code}", headers: valid_headers)
        expect(response).to(have_http_status(:ok))
        expect(data_response[:decoded_url]).to(eq(urls[index]))
      end
    end
  end
end
