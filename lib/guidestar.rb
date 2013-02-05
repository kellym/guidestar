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

    def configure
      yield self
      true
    end
  end

  Faraday.register_middleware :response,
    :raise_guidestar_error => lambda { Faraday::Response::RaiseGuidestarError }
end
