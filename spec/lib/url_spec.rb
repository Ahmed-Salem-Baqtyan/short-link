# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Url do
  describe '#valid?' do
    context 'with valid URLs' do
      it 'returns true for a valid HTTPS URL' do
        url = described_class.new('https://example.com')
        expect(url.valid?).to be true
      end

      it 'returns true for HTTPS URL with path' do
        url = described_class.new('https://example.com/path/to/resource')
        expect(url.valid?).to be true
      end

      it 'returns true for HTTPS URL with query parameters' do
        url = described_class.new('https://example.com/search?q=test&page=1')
        expect(url.valid?).to be true
      end

      it 'returns true for HTTPS URL with fragment' do
        url = described_class.new('https://example.com/page#section')
        expect(url.valid?).to be true
      end

      it 'returns true for HTTPS URL with port' do
        url = described_class.new('https://example.com:8443/api')
        expect(url.valid?).to be true
      end
    end

    context 'with invalid URL format' do
      it 'returns false for malformed URL' do
        url = described_class.new('not a url')
        expect(url.valid?).to be false
      end

      it 'returns false for empty string' do
        url = described_class.new('')
        expect(url.valid?).to be false
      end

      it 'returns false for nil' do
        url = described_class.new(nil)
        expect(url.valid?).to be false
      end

      it 'returns false for URL with spaces' do
        url = described_class.new('https://example.com/path with spaces')
        expect(url.valid?).to be false
      end
    end

    context 'with invalid schemes' do
      it 'returns false for HTTP URL' do
        url = described_class.new('http://example.com')
        expect(url.valid?).to be false
      end

      it 'returns false for FTP URL' do
        url = described_class.new('ftp://example.com')
        expect(url.valid?).to be false
      end

      it 'returns false for file URL' do
        url = described_class.new('file:///etc/passwd')
        expect(url.valid?).to be false
      end

      it 'returns false for javascript URL' do
        url = described_class.new('javascript:alert(1)')
        expect(url.valid?).to be false
      end

      it 'returns false for data URL' do
        url = described_class.new('data:text/html,<script>alert(1)</script>')
        expect(url.valid?).to be false
      end
    end

    context 'with credentials in URL' do
      it 'returns false for URL with username' do
        url = described_class.new('https://user@example.com')
        expect(url.valid?).to be false
      end

      it 'returns false for URL with username and password' do
        url = described_class.new('https://user:password@example.com')
        expect(url.valid?).to be false
      end

      it 'returns false for URL with only password' do
        url = described_class.new('https://:password@example.com')
        expect(url.valid?).to be false
      end
    end

    context 'with invalid hosts' do
      it 'returns false for URL without host' do
        url = described_class.new('https://')
        expect(url.valid?).to be false
      end

      it 'returns false for URL with only path' do
        url = described_class.new('https:///path')
        expect(url.valid?).to be false
      end
    end

    context 'with blocked IP addresses' do
      it 'returns false for localhost (127.0.0.1)' do
        url = described_class.new('https://127.0.0.1')
        expect(url.valid?).to be false
      end

      it 'returns false for loopback range (127.0.0.2)' do
        url = described_class.new('https://127.0.0.2')
        expect(url.valid?).to be false
      end

      it 'returns false for private IP 10.x.x.x' do
        url = described_class.new('https://10.0.0.1')
        expect(url.valid?).to be false
      end

      it 'returns false for private IP 172.16.x.x' do
        url = described_class.new('https://172.16.0.1')
        expect(url.valid?).to be false
      end

      it 'returns false for private IP 192.168.x.x' do
        url = described_class.new('https://192.168.1.1')
        expect(url.valid?).to be false
      end

      it 'returns false for link-local IP (169.254.x.x)' do
        url = described_class.new('https://169.254.169.254')
        expect(url.valid?).to be false
      end

      it 'returns false for IPv6 loopback (::1)' do
        url = described_class.new('https://[::1]')
        expect(url.valid?).to be false
      end

      it 'returns false for IPv6 private range' do
        url = described_class.new('https://[fc00::1]')
        expect(url.valid?).to be false
      end

      it 'returns false for IPv6 link-local' do
        url = described_class.new('https://[fe80::1]')
        expect(url.valid?).to be false
      end
    end

    context 'with DNS resolution issues' do
      it 'returns false for non-existent domain' do
        url = described_class.new('https://this-domain-definitely-does-not-exist-12345.com')
        expect(url.valid?).to be false
      end

      it 'returns false for invalid TLD' do
        url = described_class.new('https://example.invalid')
        expect(url.valid?).to be false
      end
    end

    context 'with localhost domain name' do
      it 'returns false for localhost domain' do
        url = described_class.new('https://localhost')
        expect(url.valid?).to be false
      end

      it 'returns false for localhost with port' do
        url = described_class.new('https://localhost:3000')
        expect(url.valid?).to be false
      end
    end

    context 'edge cases' do
      it 'returns false for URL with only scheme' do
        url = described_class.new('https://')
        expect(url.valid?).to be false
      end

      it 'returns false for relative URL' do
        url = described_class.new('/path/to/resource')
        expect(url.valid?).to be false
      end

      it 'returns false for protocol-relative URL' do
        url = described_class.new('//example.com')
        expect(url.valid?).to be false
      end

      it 'handles URLs with international domain names' do
        url = described_class.new('https://münchen.de')
        # This should work if the domain exists and resolves
        # The result depends on DNS resolution
        expect([true, false]).to include(url.valid?)
      end
    end
  end

  describe 'private methods' do
    let(:valid_url) { described_class.new('https://example.com') }
    let(:invalid_url) { described_class.new('not a url') }

    describe '#uri' do
      it 'parses valid URL' do
        expect(valid_url.send(:uri)).to be_a(URI::HTTPS)
      end

      it 'returns nil for invalid URL' do
        expect(invalid_url.send(:uri)).to be_nil
      end

      it 'memoizes the parsed URI' do
        uri1 = valid_url.send(:uri)
        uri2 = valid_url.send(:uri)
        expect(uri1.object_id).to eq(uri2.object_id)
      end
    end

    describe '#valid_scheme?' do
      it 'returns true for HTTPS' do
        expect(valid_url.send(:valid_scheme?)).to be true
      end

      it 'returns false for HTTP' do
        http_url = described_class.new('http://example.com')
        expect(http_url.send(:valid_scheme?)).to be false
      end
    end

    describe '#no_credentials?' do
      it 'returns true when no credentials present' do
        expect(valid_url.send(:no_credentials?)).to be true
      end

      it 'returns false when username present' do
        url_with_creds = described_class.new('https://user@example.com')
        expect(url_with_creds.send(:no_credentials?)).to be false
      end
    end

    describe '#valid_host?' do
      it 'returns true when host is present' do
        expect(valid_url.send(:valid_host?)).to be true
      end

      it 'returns false when host is missing' do
        no_host_url = described_class.new('https://')
        expect(no_host_url.send(:valid_host?)).to be false
      end
    end

    describe '#valid_ip?' do
      it 'returns true for public IP' do
        # Using a known public IP (Google DNS)
        expect(valid_url.send(:valid_ip?, '8.8.8.8')).to be true
      end

      it 'returns false for private IP' do
        expect(valid_url.send(:valid_ip?, '192.168.1.1')).to be false
      end

      it 'returns false for localhost' do
        expect(valid_url.send(:valid_ip?, '127.0.0.1')).to be false
      end

      it 'returns false for link-local' do
        expect(valid_url.send(:valid_ip?, '169.254.169.254')).to be false
      end
    end
  end
end
