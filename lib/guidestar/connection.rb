module Guidestar
  module Connection
    # Raw HTTPS connection with Faraday::Connection
    #
    # @return [Faraday::Connection]
    def connection
      return @connection if @connection
      params = {}
      @connection = Faraday.new(:url => api_url, :params => params, :headers => default_headers) do |conn|
        conn.response :mashify
        conn.response :xml, :content_type => /\bxml$/
        conn.response :raise_guidestar_error

        conn.adapter Faraday.default_adapter
      end
      @connection.proxy(self.proxy) if self.proxy
      @connection
    end
  end
end
