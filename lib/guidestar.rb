require "faraday"
require "faraday_middleware"
require "guidestar/version"
require "guidestar/client"
require "guidestar/error"
require "guidestar/result"

module Guidestar
  class << self
    attr_accessor :username
    attr_accessor :password
    attr_accessor :proxy
    attr_accessor :default_endpoint
    attr_accessor :ssl_options

    def configure
      yield self
      true
    end

    def method_missing(method_name, *args)
      Guidestar::Chain.new.send(method_name.to_sym, *args)
    end
  end

  Faraday::Response.register_middleware :raise_guidestar_error => Faraday::Response::RaiseGuidestarError
end
