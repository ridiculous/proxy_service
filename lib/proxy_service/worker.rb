require 'queue_worker'

class ProxyService::Worker < QueueWorker

  attr_accessor :message
  attr_writer :ready

  def call(message)
    @message = message
    @ready = true
  end

  def ready?
    !!@ready
  end

  def release(proxy, is_blocked)
    ack(message)
    unsubscribe
    publish(proxy) unless is_blocked
    close
  end
end
