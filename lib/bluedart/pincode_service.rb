module Bluedart
  class PincodeService < Base
    def initialize(details)
      @pincode = details[:pincode]
      @profile = profile_hash({api_type: 'S', version: '1.3'}, details[:creds])
      @mode = details[:mode]
      @timeout = details[:timeout] || 300
    end

    def request_url
      if @mode == 'prod'
        'https://netconnect.bluedart.com/Ver1.10/ShippingAPI/Finder/ServiceFinderQuery.svc'
      else
        'https://netconnect.bluedart.com/Ver1.10/Demo/ShippingAPI/Finder/ServiceFinderQuery.svc'
      end
    end

    def request_url_json
      if @mode == 'prod'
        'https://netconnect.bluedart.com/Ver1.10/Demo/ShippingAPI/Finder/ServiceFinderQuery.svc/rest/GetServicesforPincode'
      else
        'https://netconnect.bluedart.com/API-QA/Ver1.10/Demo/ShippingAPI/Finder/ServiceFinderQuery.svc/rest/GetServicesforPincode'
      end
    end

    def response
      wsa = 'http://tempuri.org/IServiceFinderQuery/GetServicesforPincode'
      opts = {message: 'GetServicesforPincode', wsa: wsa, params: {pinCode: @pincode}, extra: {'profile' => @profile}, url: request_url}
      make_request(opts)
    end

    def response_json
      params = {Request: {pinCode: @pincode}}
      opts = {message: 'GetServicesforPincode', params: params, extra: {Profile: @profile}, url: request_url_json}
      make_request_json(opts)
    end

  end
end
