module V1::ShortUrl
  class UrlValidator
    def initialize(short_url:)
      @short_url = short_url
      @url = short_url.url
      @uri = URI.parse(url)
    end

    def call
      validate_url_format
      validate_https
      validate_host
      validate_localhost
      validate_ip_address
    end

    attr_reader :short_url, :uri, :url

    def validate_url_format
      unless URI::DEFAULT_PARSER.make_regexp(%w[https]).match?(url)
        add_error("must be a valid URL")
      end
    end

    def add_error(message)
      short_url.errors.add(:url, message)
    end

    def validate_https
      unless uri.is_a?(URI::HTTPS)
        add_error("must use HTTPS")
      end
    end

    def validate_host
      if uri.host.blank?
        add_error("must have a valid host")
      end
    end

    def validate_localhost
      if uri.host == "localhost"
        add_error("localhost is not allowed")
      end
    end

    def validate_ip_address
      if ip_address?(uri.host) && private_or_loopback_ip?(uri.host)
        add_error("private or local IP addresses are not allowed")
      end
    end

    def ip_address?(host)
      IPAddr.new(host) rescue false
    end

    def private_or_loopback_ip?(host)
      IPAddr.new(host).private? || IPAddr.new(host).loopback?
    end
  end
end
