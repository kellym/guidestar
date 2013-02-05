module Guidestar
  class Result

    include Enumerable
    extend Forwardable

    def_delegators :organizations, :size, :length, :last
    def_delegators :data, :xml, :total_count, :search_time

    def initialize(path, client)
      @path = path
      @client = client
      @options = {}
      @data = Hashie::Mash.new
    end

    # Public: Contains the data we retrieve, or gets new data if there
    # are new parameters on the request.
    #
    # Returns an Array of organizations from the search
    def organizations
      return @organizations if @organizations
      load_response
      @organizations
    end

    # Internal: Contains a few extra details that might be desired, like
    # the total_count and search_time, which are also available via
    # delegation
    #
    # Returns a Hash of extra data
    def data
      return @data if @organizations
      load_response
      @data
    end

    # Public: Iterates through the inner array to make data more accessible
    def each(&block)
      organizations.each(&block)
    end

    private

    def load_response
      raw_response = @client.get_raw(@path, @options)
      @data[:xml] = ::MultiXml.parse(raw_response.body.string)['root']
      @data[:total_count] = @data[:xml]['totalResults'].to_i
      @data[:search_time] = @data[:xml]['searchTime'].to_f

      @options = {}
      @organizations = []

      orgs = @data[:xml]['organizations']['organization'] if @data[:xml]['organizations']
      return if orgs.nil?

      orgs = [orgs] unless orgs.is_a?(Array)
      orgs.each do |org|
        org = Hashie::Mash.new clean_keys(org)

        org.delete(:general_information).each do |k,v|
          org[k]=v
        end
        org.delete(:mission_and_programs).each do |type, content|
          content = Nokogiri::HTML content
          content = content.text.encode(*encoding_options).strip
          org[type] = content unless content == 'No information currently in database.'
        end

        org[:name] = org.delete :org_name
        org[:tax_deductible] = org[:deductibility] == 'Contributions are deductible, as provided by law'
        org[:result_position] = org[:result_position].to_i

        ein = org[:ein]
        def ein.to_i; self.gsub('-','').to_i; end

        @organizations << org
      end
    end

    def clean_keys(value)
      case value
      when Array
        value.map { |v| clean_keys v }
      when Hash
        Hash[value.map { |k, v| [k.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym, clean_keys(v)] }]
      else
        value.nil? ? nil : value.strip
      end
    end

    def encoding_options
      @encoding_options ||= [
        Encoding.find('ASCII'),
        {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => '',        # Use a blank for those replacements
          :universal_newline => true       # Always break lines with \n
        }
      ]
    end
    def method_missing(method_name, *args)
      @options[method_name.to_sym]=args.first
      @organizations = nil
      self
    end
  end
end


