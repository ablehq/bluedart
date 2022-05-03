module Bluedart
  class MasterData < Base
    def initialize(details)
      @last_sync_date = details[:last_sync_date]
      @profile = profile_hash({api_type: 'S', version: '1.3'}, details[:creds])
      @mode = details[:mode]
    end

    def request_url
      if @mode == 'prod'
        'https://netconnect.bluedart.com/Ver1.10/ShippingAPI/Master/MasterDownloadQuery.svc'
      else
        'https://netconnect.bluedart.com/Ver1.10/Demo/ShippingAPI/Master/MasterDownloadQuery.svc'
      end
    end

    def response
      wsa = 'http://tempuri.org/IMasterDownloadQuery/DownloadPinCodeMaster'
      params = {'request' => {'ns5:lastSynchDate' => @last_sync_date}}
      opts = {message: 'DownloadPinCodeMaster', wsa: wsa, params: params, extra: {'Profile' => @profile}, url: request_url}
      puts opts
      make_request(opts)
    end
  end
end
