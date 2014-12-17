# ProxyService

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'proxy_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proxy_service

## Usage

      ProxyService.new(:queue_name).with_mechanize do |agent|
        agent.get('http://...')
      end

## Contributing

1. Fork it ( https://github.com/ridiculous/proxy_service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
