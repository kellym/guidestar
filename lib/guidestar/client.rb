require 'forwardable'
require 'faraday/response/raise_guidestar_error'
require 'guidestar/request'
require 'guidestar/connection'
require 'guidestar/client/search'

module Guidestar
  class Client

    extend Forwardable

    include Guidestar::Request
    include Guidestar::Connection
    include Guidestar::Client::Search

    attr_reader :proxy

    attr_reader :options

    # Public: Sets up the core Client object that can be reused throughout
    # the request.
    def initialize(options={})
      @api_url     = options.delete(:endpoint) || Guidestar.default_endpoint
      @proxy       = options.delete(:proxy) || Guidestar.proxy
      @username    = options.delete(:username) || Guidestar.username
      @password    = options.delete(:password) || Guidestar.password
      @ssl_options = options.delete(:ssl_options) || Guidestar.ssl_options
      @options     = options.reverse_merge!(:version => 1.0,
                                            :page_size => 25,
                                            :page => 1 )
    end

    # Internal: Provides the URL for accessing the API
    #
    # Returns a String to the API root url.
    def api_url
      @api_url ||= 'https://gsservices.guidestar.org'
    end

    # Internal: Allows method chaining of parameters to create template
    # objects.
    #
    # Returns a Guidestar::Chain object that mimics the Client.
    def method_missing(method_name, *args)
      chain = Chain.new({
        :publisher => @publisher,
        :endpoint => @api_url,
        :proxy => @proxy
      }.merge(@options))
      chain.send(method_name.to_sym, *args)
      chain
    end
    private

    # Internal: Provides the default headers when making a request
    #
    # Returns a Hash of request headers.
    def default_headers
      headers = {
        :user_agent => 'Guidestar Ruby Gem',
        :accept => 'application/xml'
      }
    end

  end

  class Chain < Client
    attr_accessor :options
    def initialize(*args)
      @options = {}
      super
    end
    def method_missing(method_name, *args)
      @options[method_name.to_sym]=args.first
      self
    end
  end
end
