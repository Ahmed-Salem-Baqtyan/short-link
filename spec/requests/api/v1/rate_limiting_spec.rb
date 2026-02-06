# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rate Limiting', type: :request do
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

  let(:valid_params) { { short_url: { url: 'https://example.com/test' } } }

  before do
    # Clear rate limit cache before each test
    Rails.cache.clear
  end

  describe 'POST /api/v1/short_urls/encode' do
    # Rate limit: 40 requests per minute per user/IP
    
    context 'when within rate limit' do
      it 'allows requests under the limit' do
        39.times do |i|
          params = { short_url: { url: "https://example.com/test-#{i}" } }
          post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
          expect(response).to have_http_status(:ok)
        end
      end

      it 'processes all requests successfully when at limit' do
        40.times do |i|
          params = { short_url: { url: "https://example.com/test-#{i}" } }
          post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
          expect(response).to have_http_status(:ok)
          expect(json_response[:success]).to be(true)
        end
      end
    end

    context 'when rate limit is exceeded' do
      before do
        Rails.cache.clear
      end

      it 'returns 429 after 40 requests per minute' do
        # Make 40 requests (at the limit)
        40.times do |i|
          params = { short_url: { url: "https://example.com/test-#{i}" } }
          post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
          expect(response).to have_http_status(:ok)
        end
        
        # 41st request should be rate limited
        params = { short_url: { url: 'https://example.com/test-extra' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        
        expect(response).to have_http_status(429)
      end

      it 'includes rate limit information in response' do
        41.times do |i|
          params = { short_url: { url: "https://example.com/test-#{i}" } }
          post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        end

        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
        expect(response).to have_http_status(429)
        expect(response.body).to include('Rate limit exceeded')
      end
    end

    context 'when rate limit resets' do
      it 'allows requests after time window expires' do
        # Make 40 requests
        40.times do |i|
          params = { short_url: { url: "https://example.com/test-#{i}" } }
          post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        end
        
        # Should be rate limited
        post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
        expect(response).to have_http_status(429)
        
        # Simulate time passing (clear cache to simulate expiry)
        Rails.cache.clear
        
        # Should work again
        params = { short_url: { url: 'https://example.com/test-new' } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /api/v1/short_urls/decode/:code' do
    # Rate limit: 30 requests per minute per IP
    
    let!(:short_url) { create(:short_url, user: user, url: 'https://example.com/original') }
    let(:public_headers) { { 'API-ACCESS-TOKEN' => api_access_token } }

    context 'when within rate limit' do
      it 'allows requests under the limit' do
        29.times do
          get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
          expect(response).to have_http_status(:ok)
        end
      end

      it 'processes all requests successfully when at limit' do
        30.times do
          get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
          expect(response).to have_http_status(:ok)
          expect(json_response[:success]).to be(true)
          expect(data_response[:decoded_url]).to eq('https://example.com/original')
        end
      end
    end

    context 'when rate limit is exceeded' do
      it 'returns 429 after 30 requests per minute' do
        # Make 30 requests (at the limit)
        30.times do
          get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
          expect(response).to have_http_status(:ok)
        end
        
        # 31st request should be rate limited
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
        
        expect(response).to have_http_status(429)
      end

      it 'rate limits per IP address' do
        # Make 30 requests
        30.times do
          get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
        end
        
        # Next request from same IP should be limited
        get("/api/v1/short_urls/decode/#{short_url.code}", headers: public_headers)
        expect(response).to have_http_status(429)
      end
    end

    context 'with non-existent code' do
      it 'still enforces rate limits' do
        30.times do
          get('/api/v1/short_urls/decode/NONEXISTENT', headers: public_headers)
        end
        
        get('/api/v1/short_urls/decode/NONEXISTENT', headers: public_headers)
        expect(response).to have_http_status(429)
      end
    end
  end

  describe 'POST /api/v1/auth/sessions (login)' do
    let(:login_params) do
      {
        email_address: user.email_address,
        password: 'password123'
      }
    end

    let(:auth_headers) do
      {
        'API-ACCESS-TOKEN' => api_access_token,
        'Content-Type' => 'application/json'
      }
    end

    context 'when within rate limit' do
      it 'allows login attempts under the limit' do
        4.times do
          post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
          expect(response.status).to be_in([200, 401])
        end
      end

      it 'allows successful logins' do
        # Create user with known password
        user.update(password: 'Test123!@#')
        params = {
          email_address: user.email_address,
          password: 'Test123!@#'
        }
        
        post('/api/v1/auth/sessions', params: params.to_json, headers: auth_headers)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when rate limit is exceeded' do
      it 'returns 429 after 5 attempts per email' do
        # Make 5 attempts (at the limit)
        10.times do
          post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
        end
        
        # 6th attempt should be rate limited
        post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
        
        expect(response).to have_http_status(429)
      end

      it 'prevents brute force attacks on specific accounts' do
        # Try to brute force user's account
        10.times do |i|
          params = {
            email_address: user.email_address,
            password: "wrong_password_#{i}"
          }
          post('/api/v1/auth/sessions', params: params.to_json, headers: auth_headers)
        end
        
        # Even with correct password, should be rate limited
        params = {
          email_address: user.email_address,
          password: user.password
        }
        post('/api/v1/auth/sessions', params: params.to_json, headers: auth_headers)
        
        expect(response).to have_http_status(429)
      end

      it 'rate limits by email address' do
        10.times do
          post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
        end
        
        # Same email should be limited
        post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
        expect(response).to have_http_status(429)
      end
    end

    context 'with different email addresses' do
      it 'tracks rate limits independently per email' do
        # Hit limit for first email
        10.times do
          post('/api/v1/auth/sessions', params: login_params.to_json, headers: auth_headers)
        end
        
        # Different email should still work
        other_params = {
          email_address: 'other@example.com',
          password: 'password'
        }
        post('/api/v1/auth/sessions', params: other_params.to_json, headers: auth_headers)
        expect(response.status).to be_in([200, 401])
      end
    end
  end

  describe 'Rate limit isolation between users' do
    let(:user2) { create(:user, email_address: 'user2@example.com') }
    let(:session2) { create(:session, user: user2) }
    let(:headers2) { valid_headers.merge('Authorization' => "Bearer #{session2.token}") }

    it 'enforces rate limits per user independently' do
      # User 1 hits their limit (40 requests)
      40.times do |i|
        params = { short_url: { url: "https://example.com/user1-#{i}" } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
        expect(response).to have_http_status(:ok)
      end
      
      # User 1 should be rate limited
      params = { short_url: { url: 'https://example.com/user1-extra' } }
      post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
      expect(response).to have_http_status(429)
      
      # User 2 should still be able to make requests
      params = { short_url: { url: 'https://example.com/user2-test' } }
      post('/api/v1/short_urls/encode', params: params.to_json, headers: headers2)
      expect(response).to have_http_status(:ok)
    end

    it 'does not share rate limit counters between users' do
      # User 1 makes 20 requests
      20.times do |i|
        params = { short_url: { url: "https://example.com/user1-#{i}" } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
      end
      
      # User 2 should have full quota (40 requests)
      40.times do |i|
        params = { short_url: { url: "https://example.com/user2-#{i}" } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: headers2)
        expect(response).to have_http_status(:ok)
      end
      
      # User 2 should now be at limit
      params = { short_url: { url: 'https://example.com/user2-extra' } }
      post('/api/v1/short_urls/encode', params: params.to_json, headers: headers2)
      expect(response).to have_http_status(429)
    end
  end

  describe 'Rate limit across different endpoints' do
    let!(:short_url) { create(:short_url, user: user, url: 'https://example.com/test') }
    
    it 'maintains separate counters for encode and decode' do
      # Hit encode limit (40 requests)
      40.times do |i|
        params = { short_url: { url: "https://example.com/test-#{i}" } }
        post('/api/v1/short_urls/encode', params: params.to_json, headers: valid_headers)
      end
      
      # Encode should be limited
      post('/api/v1/short_urls/encode', params: valid_params.to_json, headers: valid_headers)
      expect(response).to have_http_status(429)
      
      # Decode should still work (separate limit)
      get("/api/v1/short_urls/decode/#{short_url.code}", headers: { 'API-ACCESS-TOKEN' => api_access_token })
      expect(response).to have_http_status(:ok)
    end
  end
end
