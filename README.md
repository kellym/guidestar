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

    results = Guidestar.search(:keyword => 'monkeys', :limit => 20)

Or you can create a Guidestar::Client object and go from there:

    client  = Guidestar::Client.new
    results = client.search(:keyword => 'monkeys', :limit => 20)
    # OR
    results = client.keyword('monkeys').per(20).search
    # or any combination of the above methods

There are four main API methods that you can use:

    Guidestar.search            # this is the only tested method on this repo
    Guidestar.detailed_search
    Guidestar.charity_check
    Guidestar.npo_validation

See https://gsservices.guidestar.org/GuideStar_SearchService/WebServiceSearchQuery.xsd
for detailed search parameters.

The Guidestar::Result object behaves like an array, but includes some extra
fields for your usage:

    results.xml
    # => raw xml data

    results.search_time
    # => 0.12

    results.total_count
    # => 1292

    results.total_pages
    # => 52

You can iterate through the results like any Enumerable:

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

    results.page(2).each { |more_orgs| puts more_orgs.name }

If you should ever need direct access to the array of results, just hit:

    results.organizations

Ruby APIs should be super flexible in usage, so this gem lets you access the
data how you want.  Pass in your options all at once or chain them.  Create a new
search or use the result to paginate or adjust the search as needed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
