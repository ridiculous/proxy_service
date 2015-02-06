require 'json'

class ProxyService

  class << self
    attr_accessor :proxies_enabled, :username, :password, :failure_limit, :failure_codes

    def configure
      yield self
    end
  end

  attr_accessor :source, :failure_limit, :failure_codes
  attr_writer :proxies_enabled
  attr_reader :proxy

  # = Create a new proxy service with for a specific ODS
  #
  # @param [String, Symbol] source name of the ODS (e.g. :trip_advisor), will look for a queue with that name "proxy/#{source}"
  # @param [Hash] options
  # @option options [Boolean] :proxies_enabled override the class configuration
  # @option options [Integer] :failure_limit before blocking the proxy
  # @option options [Array]   :failure_codes that indicate a proxy was blocked by the site
  def initialize(source, options = {})
    @source = source
    @proxies_enabled = options.fetch(:proxies_enabled, !!self.class.proxies_enabled)
    @failure_limit = options.fetch(:failure_limit, self.class.failure_limit || 3)
    @failure_codes = options.fetch(:failure_codes, self.class.failure_codes || %w[403])
  end

  # @yield [agent] Passes a [proxied] Mechanize agent to the block
  def with_mechanize
    @proxy = reserve_proxy
    agent = MechanizeAgent.new
    agent.set_proxy(proxy)
    yield agent
    proxy.reset_failures
  rescue Mechanize::ResponseCodeError => e
    block_or_increment_proxy if failure_codes.include?(e.response_code)
  rescue ProxyBlockedError, ReCaptchaError
    block_or_increment_proxy
  ensure
    proxy.release
  end

  #
  # Private
  #

  def block_or_increment_proxy
    if proxy.failures >= failure_limit
      proxy.blocked!
    else
      proxy.increment_failures
    end
  end

  def proxies_enabled?
    @proxies_enabled
  end

  # = Sleeps until the worker receives a proxy (message)
  #
  # @return [Proxy] a new proxy object
  def reserve_proxy
    worker = new_worker
    worker.subscribe
    loop do
      if worker.ready?
        return Proxy.new(worker)
      else
        sleep(1)
      end
    end
  end

  def new_worker
    if proxies_enabled?
      Worker.new("proxy/#{source}")
    else
      NullWorker.new
    end
  end

  #
  # Custom errors
  #

  class ProxyBlockedError < StandardError
  end

  class ReCaptchaError < StandardError
  end
end

require 'proxy_service/mechanize_agent'
require 'proxy_service/null_worker'
require 'proxy_service/proxy'
require 'proxy_service/worker'
