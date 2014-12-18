# ProxyService

A service class that rotates a list of proxies stored in a queue. The queueing system must support the STOMP protocol. Can be used with or without proxies and prepares a Mechanize agent that is passed a block. A queue name should be given and that queue should have a list of proxies in the format of `{ failures: 0, ip: '127.0.0.1', port: '80' }`. The service uses this info to set the proxy of a mechanize agent. If an exception occurs in the block, the proxy's `:failures` count is incremented and it's put back in the queue to be used again. Once the `:failures` count exceeds the `#failure_limit` it will be removed the queue.

## Installation

Add this line to your application's Gemfile:

    gem 'proxy_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proxy_service

## Usage
Configure the service, for example, in an initializer
```ruby
ProxyService.configure do |config|
  config.proxies_enabled = true
  config.username = '...'  # only used when proxies enabled
  config.password = '...'  # only used when proxies enabled
  config.failure_limit = 3 # only used when proxies enabled
end
```
And then use it in your app
```ruby
ProxyService.new(:queue_name).with_mechanize do |agent|
  agent.get('http://...')
end
```
Some config settings can be overwritten on initialize
```ruby
ProxyService.new('queue', proxies_enabled: false)
```
## Contributing

1. Fork it ( https://github.com/ridiculous/proxy_service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
