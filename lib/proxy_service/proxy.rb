class ProxyService::Proxy

  attr_accessor :worker
  attr_writer :failures, :message, :ip, :port

  # @param [Worker, NullWorker] worker that has a message and body
  def initialize(worker)
    @worker = worker
  end

  def ip
    @ip ||= message['ip']
  end

  def port
    @port ||= message['port']
  end

  def failures
    @failures ||= message['failures']
  end

  def message
    @message ||= { 'failures' => 0 }.merge(JSON.parse(worker.message.body))
  end

  def release
    worker.release(self, blocked?)
  end

  def increment_failures
    @failures += 1
  end

  def reset_failures
    @failures = 0
  end

  def blocked?
    !!@blocked
  end

  def blocked!
    @blocked = true
  end

  #
  # Coercion overrides
  #

  def to_h
    {
      ip: ip,
      port: port,
      failures: failures
    }
  end

  def to_json
    to_h.to_json
  end

  def to_s
    %(#<Proxy:#{object_id} @ip="#{ip}", @port="#{port}", @failures=#{failures}, @blocked=#{blocked?}, @message=#{message}, @worker="...">)
  end

  alias inspect to_s

end
