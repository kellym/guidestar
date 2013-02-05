module Guidestar
  class Result
    #
    # Public: Returns the String xml of the response from Guidestar
    attr_reader :xml

    # Public: Returns the Integer number of results from the query
    attr_reader :total_count

    # Public: Returns the Float time in seconds to search
    attr_reader :search_time

    # Public: Returns an Array of organizations from the search
    def organizations
      return @organizations if @organizations
      parse_xml(@client.get_raw(@path, @options))
      @organizations
    end

    def initialize(raw_response, path, client)
      @path = path
      @client = client
      parse_xml(raw_response)
    end

    private

    def parse_xml(raw_response)
      @xml = ::MultiXml.parse(raw_response.body.string)['root']
      @total_count = @xml['totalResults'].to_i
      @search_time = @xml['searchTime'].to_f
      @options = {}

      @organizations = []
      orgs = @xml['organizations']['organization']
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


