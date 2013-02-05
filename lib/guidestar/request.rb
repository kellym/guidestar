module Guidestar
  module Request

    def get(path, data={})
      set_params(data)
      Guidestar::Result.new(path,self)
    end

    def get_raw(path, data={})
      response = connection.get do |request|
       request.url("/GuideStar_SearchService/searchservice.asmx#{path}", set_params(data))
      end
      response if response.status == 200
    end

    private

    def set_params(data={})
      @options.merge!(data)
      @options[:page_size]  = @options.delete(:limit)     if @options[:limit]
      @options[:page_size]  = @options.delete(:per)       if @options[:per]
      @options[:zip_radius] = @options.delete(:zipradius) if @options[:zipradius]
      @options[:org_name]   = @options.delete(:name)      if @options[:name]
      @options[:offset]     = (@options.delete(:page)-1) * @options[:page_size].to_i if @options[:page]
      @options[:ein]        = @options[:ein].to_s.insert(2,'-') if @options[:ein] && @options[:ein].to_s[2] != '-'
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.query do
          xml.version @options[:version]
          xml.login @username
          xml.password @password
          xml.pageSize @options[:page_size]
          xml.offset @options[:offset]
          xml.keyword @options[:keyword]      if @options[:keyword]
          xml.city @options[:city]            if @options[:city]
          xml.state @options[:state]          if @options[:state]
          xml.zip @options[:zip]              if @options[:zip]
          zml.zipradius @options[:zip_radius] if @options[:zip_radius]
          xml.ein @options[:ein]              if @options[:ein]
          xml.orgName @options[:org_name]     if @options[:org_name]
          if @options[:categories] && @options[:categories].is_a?(Array)
            @options[:categories].each {|category| xml.category category }
          end

          if @options[:sub_categories] && @options[:sub_categories].is_a?(Array)
            @options[:sub_categories].each {|sub_category| xml.subCategory sub_category }
          end

          xml.nteeCode @options[:ntee_code]  if @options[:ntee_code]
        end
      end
      {:xmlInput => builder.to_xml}
    end
  end
end

