require 'nokogiri'
require 'httparty'
require 'nori'

module Bluedart
  class Base
    def initialize(details)
      @timeout = details[:timeout] || 120
      @debug = details[:debug] || false
      @comms_mode = details[:comms_mode] || "xml"
    end

    def is_comms_mode_xml?
      @comms_mode == "xml"
    end

    private

    # input params
    # details - Hash
    # creds - Hash
    #
    # Creates profile hash
    #
    # Return Hash
    def profile_hash(details, creds)
      params = {}
      if is_comms_mode_xml?
        params[:api_type] = details[:api_type]
        params[:license_key] = creds[:license_key]
        params[:login_id] = creds[:login_id]
        params[:version] = details[:version]
      else
        params[:Api_type] = details[:api_type]
        params[:LicenceKey] = creds[:license_key]
        params[:LoginID] = creds[:login_id]
        params[:Version] = '1.8'
      end
      params
    end

    # input params - none
    #
    # Creates hash containing required namespaces
    #
    # Returns Hash
    def namespaces
      ns = {}
      ns[:envelope] = {key:'env', value: 'http://www.w3.org/2003/05/soap-envelope'}
      ns[:content]  = {key:'ns1', value: 'http://tempuri.org/'}
      ns[:profile]  = {key:'ns2', value: 'http://schemas.datacontract.org/2004/07/SAPI.Entities.Admin'}
      ns[:wsa]      = {key:'ns3', value: 'http://www.w3.org/2005/08/addressing'}
      ns[:shipment] = {key:'ns4', value: 'http://schemas.datacontract.org/2004/07/SAPI.Entities.WayBillGeneration'}
      ns[:pickup]   = {key:'ns5', value: 'http://schemas.datacontract.org/2004/07/SAPI.Entities.Pickup'}
      ns
    end

    # input params - none
    #
    # Creates hash with xml styled namespace key and value
    #
    # Returns Hash
    def namespace_hash
      opt = {}
      namespaces.each do |type, attrs|
        key = "xmlns:#{attrs[:key]}"
        opt[key] = attrs[:value]
      end
      opt
    end

    # input params
    # name - symbol
    #
    # Provides key for a given namespace block
    #
    # Returns String
    def namespace_key(name)
      namespaces[name][:key]
    end

    # input params
    # xml - Nokogiri::XML::Builder
    # values - Hash
    #
    # Appends Profile XML Block
    #
    # Returns Nokogiri::XML::Builder
    def profile_xml(xml, values)
      ns_key = "#{namespace_key(:profile)}"
      xml[ns_key].Api_type values[:api_type]
      xml[ns_key].LicenceKey values[:license_key]
      xml[ns_key].LoginID values[:login_id]
      xml[ns_key].Version values[:version]
      xml
    end

    # input params
    # xml - Nokogiri::XML::Builder
    # wsa - string
    #
    # Appends Header XML Block
    #
    # Returns Nokogiri::XML::Builder
    def header_xml(xml, wsa)
      xml.Header {
        xml["#{namespace_key(:wsa)}"].Action(wsa, "#{namespace_key(:envelope)}:mustUnderstand" => true)
      }
      xml
    end

    # input params
    # xml - Nokogiri::XML::Builder
    # params - Hash
    #
    # Transform Hash to XML
    #
    # Returns Nokogiri::XML::Builder
    def hash_xml(xml, params)
      params.each do |key, value|
        xml = xml_key_value(key, value, xml)
      end
      xml
    end

    # TODO: ITS A HACK NEEDS TO BE REMOVED
    # input params
    # key - string
    #
    # Removes last letter from string
    #
    # Returns String
    def singular(key)
      key = key[0..-2]
    end

    def xml_key_value(key, value, xml)
      if value.is_a?(Hash)
        xml.send(key) do |xml|
          value.each {|inner_key, inner_values| xml = xml_key_value(inner_key, inner_values, xml)}
        end
      elsif value.is_a?(Array)
        xml.send(key) do |xml|
          value.each do |single_value|
            xml = hash_xml(xml, single_value)
          end
        end  
      else
        xml.send(key, value)
      end
      xml
    end

    # input params
    # xml - Nokogiri::XML::Builder
    # message - String
    # params - Hash
    # extra - Hash
    #
    # Appends Body XML Block
    #
    # Returns Nokogiri::XML::Builder
    def body_xml(xml, message, params, extra)
      content_ns_key = "#{namespace_key(:content)}"
      xml.Body {
        xml[content_ns_key].send(message) do |xml|
          hash_xml(xml, params)
          extra.each do |key, value|
            xml[content_ns_key].send(key) { profile_xml(xml, value)} if key.downcase == 'profile'
          end
        end
      }
      xml
    end

    # input params
    # opts - Hash
    #
    # Create XML Request
    #
    # Returns Nokogiri::XML::Builder
    def request_xml(opts)
      envelope_ns_key = "#{namespace_key(:envelope)}"
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml[envelope_ns_key].Envelope(namespace_hash) {
          xml = header_xml(xml, opts[:wsa])
          xml = body_xml(xml, opts[:message], opts[:params], opts[:extra])
        }
      end
    end

    def request_json(opts)
      {}.merge(opts[:params] || {}).merge(opts[:extra] || {})
    end

    # input params
    # opts - Hash
    #
    # Fire XML request and return parsed response
    #
    # Returns Hash
    def make_request(opts)
      body = request_xml(opts)
      response = request(opts[:url], body.to_xml)
      response_return(response, opts[:message])
    end

    def make_request_json(opts)
      body = request_json(opts)
      transformed = body.except(:Profile).except(:profile).deep_transform_keys do |key|
        if key == "pinCode".to_sym
          key
        else
          key.to_s.camelize(:upper)
        end
      end
      if body.key?(:Profile)
        body = transformed.merge(Profile: body[:Profile])
      elsif body.key?(:profile)
        body = transformed.merge(profile: body[:profile])
      end
      response = run_json_request(opts[:url], body)
      response_return_json(response, opts[:message])
    end

    # input params
    # response - Hash
    # message - String
    #
    # Provides Parsed Response
    #
    # Returns Hash
    def response_return(response, message)
      response_hash = {error: false, error_text: ''}
      if response[:error]
        response_hash[:error] = true
        response_hash[:error_text] = response[:error_message]
      else
        content = required_content(message, response)
        if content[:is_error] || content[:error]
          response_hash[:error] = true
          response_hash[:error_text] = content[:error_message] || content[:status] || content[:error_text]
        else
          response_hash[:content] = content
        end
      end
      response_hash
    end

    def response_return_json(response, message)
      response_hash = {error: false, error_text: ''}
      if response[:error]
        response_hash[:error] = true
        response_hash[:error_text] = response[:error_message]
      else
        content = required_content_json(message, response)
        if content[:is_error] || content[:error]
          response_hash[:error] = true
          response_hash[:error_text] = content[:error_message] || content[:status] || content[:error_text]
        else
          response_hash[:content] = content
        end
      end
      response_hash
    end

    # input params
    # prefix - String
    # content - Hash
    #
    # Removes Junk content from response
    #
    # Returns Hash
    def required_content(prefix, content)
      if content[:fault].nil?
        prefix_s = prefix.snakecase
        keys = (prefix_s + '_response').to_sym, (prefix_s + '_result').to_sym
        return content[keys[0]][keys[1]]
      else
        return {error: true, error_text: content[:fault]}
      end
    end

    def required_content_json(prefix, content)
      if content[:fault].nil?
        prefix_s = prefix.snakecase
        key = prefix_s + '_result'
        return content[key.to_sym]
      else
        return {error: true, error_text: content[:fault]}
      end
    end

    # input params
    # url - String
    # body - String
    #
    # Fires request and returns response
    #
    # Returns Hash
    def request(url, body)
      opts = {
        body: body, 
        headers: {'Content-Type': 'application/soap+xml; charset="utf-8"'},
        verify: false, 
        timeout: @timeout
      }
      if @debug
        opts.merge!(debug_output: $stdout)
      end
      res = HTTParty.post(url, opts)
      content = xml_hash(res.body)[:envelope][:body]
    end

    def run_json_request(url, body)
      opts = {
        body: body.to_json, 
        headers: {'Content-Type': 'application/json; charset="utf-8"'},
        verify: false, 
        timeout: @timeout
      }
      if @debug
        opts.merge!(debug_output: $stdout)
      end
      res = HTTParty.post(url, opts)
      JSON.parse(res.body).deep_transform_keys{ |key| key.to_s.underscore }.deep_symbolize_keys
    end

    # input params
    # xml - String
    #
    # Converts XML to Hash
    #
    # Returns Hash
    def xml_hash(xml)
      nori = Nori.new(strip_namespaces: true, :convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
      nori.parse(xml)
    end

    # input params
    # address - String
    # line_length - Integer
    #
    # Splits address into array by count of characters
    #
    # Returns Array
    def multi_line_address(address, line_length)
      multi_line_address_block = []
      i = 0
      address.split(/[ ,]/).each do |s|
        if multi_line_address_block[i].blank?
          multi_line_address_block[i] = s
        elsif (multi_line_address_block[i].length + s.length < line_length)
          multi_line_address_block[i] += ' ' + s
        else
          i += 1
          multi_line_address_block[i] = s
        end
      end
      multi_line_address_block
    end
  end
end