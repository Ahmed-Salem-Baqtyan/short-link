# app/lib/url.rb

require "resolv"
require "ipaddr"

class Url
  BLOCKED_IP_RANGES = [
    IPAddr.new("127.0.0.0/8"),      # Loopback
    IPAddr.new("10.0.0.0/8"),       # Private
    IPAddr.new("172.16.0.0/12"),    # Private
    IPAddr.new("192.168.0.0/16"),   # Private
    IPAddr.new("169.254.0.0/16"),   # Link-local (includes cloud metadata services)
    IPAddr.new("::1"),              # IPv6 loopback
    IPAddr.new("fc00::/7"),         # IPv6 private
    IPAddr.new("fe80::/10")         # IPv6 link-local
  ].freeze

  def initialize(url)
    @url = url
  end

  attr_reader :url

  def valid?
    return false unless uri

    valid_scheme? &&
      no_credentials? &&
      valid_host? &&
      valid_dns_resolution?
  end

  private

  def uri
    @uri ||= begin
      URI.parse(url)
    rescue URI::InvalidURIError
      nil
    end
  end

  def valid_scheme?
    uri.is_a?(URI::HTTPS)
  end

  def no_credentials?
    uri.user.blank? && uri.password.blank?
  end

  def valid_host?
    uri.host.present?
  end

  def valid_dns_resolution?
    addresses = Resolv.getaddresses(uri.host)

    return false if addresses.empty?

    addresses.all? { |ip| valid_ip?(ip) }
  rescue Resolv::ResolvError
    false
  end

  def valid_ip?(ip)
    ip_addr = IPAddr.new(ip)
    BLOCKED_IP_RANGES.none? { |range| range.include?(ip_addr) }
  end
end
