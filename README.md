# Guidestar


## Installation

Add this line to your application's Gemfile:

    gem 'guidestar'

Or install it yourself as:

    $ gem install guidestar

Then configure it with an initializer like `/config/initializers/guidestar.rb`:

    Guidestar.configure do |config|
      config.username = 'john@guidestar.org'
      config.password = 'l3tm31n'
    end

## Usage

Once you initialize it, you can use it in your code via:

    client  = Guidestar::Client.new
    results = client.search(:keyword => 'monkeys', :limit => 20)

    results.xml
    # => raw xml data

    results.search_time
    # => 0.12
    results.total_count
    # => 1292

    results.each do |org|
      org.name
      # => 'Monkey Paradise'
      org.ein
      # => '23-5553434'
      org.ein.to_i # with some magic
      # => 235553434
      org.tax_deductible?
      # true
    end

For getting the next page of results, it behaves similarly to kaminari or will_paginate:

    results.per(50).page(2).each { |more_orgs| puts more_orgs.name }

If you need more direct access to the array of results, just hit:

    results.organizations

The way you use it is all super-flexible.  You can pass in your options beforehand or
chain them along the way.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
