require 'mechanize'

class ProxyService::MechanizeAgent < DelegateClass(Mechanize)
  USER_AGENT_ALIASES = ['Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox']

  def initialize
    super Mechanize.new do |mech|
      mech.open_timeout = 10
      mech.read_timeout = 10
      mech.follow_meta_refresh = true
      mech.keep_alive = true
      mech.max_history = 1
      mech.user_agent_alias = USER_AGENT_ALIASES.sample
    end
  end

  # @note proxy.ip should only be nil in the case where it's held by a NullWorker
  # @param [#ip, #port] proxy object that holds the ip and port
  def set_proxy(proxy)
    return unless proxy.ip
    __getobj__.set_proxy(proxy.ip, proxy.port, ProxyService.username, ProxyService.password)
  end
end
