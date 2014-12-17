require 'json'

class ProxyService

  POLL_PERIOD = 1
  MAX_FAILURES = 3

  class << self
    attr_accessor :proxies_enabled, :username, :password

    def configure
      yield self
    end
  end

  attr_accessor :source
  attr_writer :proxies_enabled

  # = Create a new proxy service with for a specific ODS
  #
  # @example
  #
  #   ProxyService.new(:queue_name).with_mechanize do |agent|
  #     agent.get('...')
  #   end
  #
  # @param [String|Symbol] source name of the ODS (e.g. :tripadvisor), will look for a queue with that name "proxy/#{source}"
  # @param [Hash] options
  # @option options [Boolean] :proxies_enabled override the app configuration
  def initialize(source, options = {})
    @source = source
    @proxies_enabled = options.fetch(:proxies_enabled, !!self.class.proxies_enabled)
  end

  # @yield [agent] Passes a [proxied] Mechanize agent to the block
  def with_mechanize
    proxy = reserve_proxy
    agent = MechanizeAgent.new
    agent.set_proxy(proxy)
    yield agent
    proxy.reset_failures
  rescue => e
    if proxy.failures >= MAX_FAILURES
      proxy.blocked!
    else
      proxy.increment_failures
    end
    puts "ERROR: #{e.message}"
  ensure
    proxy.release
  end

  #
  # Private
  #

  def new_worker
    if proxies_enabled?
      Worker.new("proxy/#{source}")
    else
      NullWorker.new
    end
  end

  def proxies_enabled?
    @proxies_enabled
  end

  # = Creates a STOMP connection (consumer)
  #
  # @return [Proxy] a new proxy object
  def reserve_proxy
    worker = new_worker
    worker.subscribe
    loop do
      if worker.ready?
        return Proxy.new(worker)
      else
        sleep(POLL_PERIOD)
      end
    end
  end
end

require 'proxy_service/mechanize_agent'
require 'proxy_service/null_worker'
require 'proxy_service/proxy'
require 'proxy_service/worker'
