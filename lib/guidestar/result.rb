module Guidestar
  class Result

    include Enumerable
    extend Forwardable

    def_delegators :all, :size, :length, :last
    def_delegators :data, :xml, :total_count, :search_time, :total_pages

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
    def all
      return @organizations if @organizations
      load_response
      @organizations
    end
    alias :organizations :all

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
      @data[:total_pages] = (@data[:total_count].to_f / @client.options[:page_size]).ceil
      @data[:search_time] = @data[:xml]['searchTime'].to_f

      @options = {}
      @organizations = []

      orgs = @data[:xml]['organizations']['organization'] if @data[:xml]['organizations']
      return if orgs.nil?

      orgs = [orgs] unless orgs.is_a?(Array)
      orgs.each do |org|
        org = Hashie::Mash.new clean_result(org)

        general_information = org.delete(:general_information) || {}
        general_information.each do |k,v|
          org[k]=v
        end
        mission_and_programs = org.delete(:mission_and_programs) || {}
        mission_and_programs.each do |type, content|
          content = Nokogiri::HTML content
          content = content.text.encode(*encoding_options).strip
          org[type] = content unless content == 'No information currently in database.'
        end
        ntees = org.delete(:ntees)
        if ntees
          org.ntees = {}
          ntees[:ntee].each do |ntee|
            org.ntees[ntee.code] = ntee.description unless ntee.code.nil?
          end
        end

        org[:world_locations] = org.delete(:world_locations).to_s.split(', ') if org[:word_locations]
        org[:us_locations]    = org.delete(:us_locations).to_s.split(', ') if org[:us_locations]

        # number fields
        %w(ruling_year year_founded assets income).each do |field|
          org[field] = org[field].to_i if org[field]
        end

        org[:zip_code] = org.delete :zip
        org[:name] = org.delete :org_name
        org[:tax_deductible] = org[:deductibility] == 'Contributions are deductible, as provided by law'
        org[:type] = org[:irs_subsection].split(' ').first.gsub(/\W/,'').to_sym if org[:irs_subsection]
        org["is_#{org[:type]}"] = true if org[:type]

        org[:ein] = EIN.new org[:ein]

        @organizations << org
      end
    end

    def clean_result(value)
      case value
      when Array
        value.map { |v| clean_result v }
      when Hash
        Hash[value.map { |k, v| [k.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym, clean_result(v)] }]
      else
        if value.nil?
          nil
        else
          value.strip
        end
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

    class EIN < ::String
      def to_i
        self.to_s.gsub('-','').to_i
      end
    end

  end
end


