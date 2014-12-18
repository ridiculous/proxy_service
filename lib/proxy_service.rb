require 'json'

class ProxyService

  class << self
    attr_accessor :proxies_enabled, :username, :password, :failure_limit

    def configure
      yield self
    end
  end

  attr_accessor :source, :failure_limit
  attr_writer :proxies_enabled

  # = Create a new proxy service with for a specific ODS
  #
  # @param [String|Symbol] source name of the ODS (e.g. :tripadvisor), will look for a queue with that name "proxy/#{source}"
  # @param [Hash] options
  # @option options [Boolean] :proxies_enabled override the class configuration
  # @option options [Integer] :failure_limit before blocking the proxy
  def initialize(source, options = {})
    @source = source
    @proxies_enabled = options.fetch(:proxies_enabled, !!self.class.proxies_enabled)
    @failure_limit = options.fetch(:failure_limit, self.class.failure_limit || 3)
  end

  # @yield [agent] Passes a [proxied] Mechanize agent to the block
  def with_mechanize
    proxy = reserve_proxy
    agent = MechanizeAgent.new
    agent.set_proxy(proxy)
    yield agent
    proxy.reset_failures
  rescue
    if proxy.failures >= failure_limit
      proxy.blocked!
    else
      proxy.increment_failures
    end
  ensure
    proxy.release
  end

  #
  # Private
  #

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
end

require 'proxy_service/mechanize_agent'
require 'proxy_service/null_worker'
require 'proxy_service/proxy'
require 'proxy_service/worker'
