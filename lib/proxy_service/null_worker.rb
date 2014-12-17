class ProxyService::NullWorker
  NullMessage = Struct.new(:body)
  attr_accessor :message

  def initialize
    @message = NullMessage.new('{}')
  end

  def call(*)
    # no-op
  end

  def ready?
    true
  end

  def subscribe
    # no-op
  end

  def release(*)
    # no-op
  end
end
