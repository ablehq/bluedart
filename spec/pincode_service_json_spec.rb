require 'spec_helper'

describe "Pincode service json communication mode" do
  it 'should get pincode service details' do
    details ={
      pincode: "500062",
      comms_mode: "json",
      mode: "development",
      debug: true,
      creds: {
        license_key: "lk",
        login_id: "ld"
      }
    }
    response_body = {
        "GetServicesforPincodeResult": {
            "AdditionalTTDays": "0",
            "AirValueLimit": 200000,
            "AirValueLimiteTailPrePaid": 1000000,
            "ApexCODIntraStateValLimit": 200000,
            "ApexDODServiceInbound": "Yes",
            "ApexDODServiceOutbound": "Yes",
            "ApexEDLAddDays": "0",
            "ApexEDLDist": "0",
            "ApexETailTDD10Inbound": "No",
            "ApexETailTDD10Outbound": "Yes",
            "ApexETailTDD12Inbound": "Yes",
            "ApexETailTDD12Outbound": "Yes",
            "ApexEconomyInbound": "Yes",
            "ApexEconomyOutbound": "Yes",
            "ApexEtailRVP": "Full RVP",
            "ApexFODServiceInbound": "Yes",
            "ApexFODServiceOutbound": "Yes",
            "ApexInbound": "Yes",
            "ApexOutbound": "Yes",
            "ApexPrepaidIntraStateValLimit": 1000000,
            "ApexTDD": "O/B only",
            "ApexZone": "South     ",
            "AreaCode": "HYD",
            "BlueDartHolidays": [
                {
                    "Description": "SUNDAY",
                    "HolidayDate": "/Date(1687631400000+0530)/"
                },
                {
                    "Description": "SUNDAY",
                    "HolidayDate": "/Date(1688236200000+0530)/"
                }
            ],
            "CCServiceInbound": "Yes",
            "CCServiceOutbound": "Yes",
            "CityDescription": "HYDERABAD",
            "DPCODServiceInbound": "Yes",
            "DPCODServiceOutbound": "Yes",
            "DPDutsValueLimit": 500000,
            "DPNewZone": "A1",
            "DPTDD10Inbound": "No",
            "DPTDD10Outbound": "Yes",
            "DPTDD12Inbound": "Yes",
            "DPTDD12Outbound": "Yes",
            "DPZone": "A",
            "DSPServiceInbound": "Yes",
            "DSPServiceOutbound": "Yes",
            "DartPlusRVP": "Full RVP",
            "DomesticPriorityInbound": "Yes",
            "DomesticPriorityOutbound": "Yes",
            "DomesticPriorityTDD": "12:00",
            "ECOMZone": "A",
            "EDLAddDays": "0",
            "EDLDist": "0",
            "EDLProduct": "",
            "Embargo": "No",
            "ErrorMessage": "Valid",
            "ExchangeService": "Yes",
            "GroundDODServiceInbound": "Yes",
            "GroundDODServiceOutbound": "Yes",
            "GroundEDLAddDays": "0",
            "GroundEDLDist": "0",
            "GroundFODServiceInbound": "Yes",
            "GroundFODServiceOutbound": "Yes",
            "GroundInbound": "Yes",
            "GroundOutbound": "Yes",
            "GroundRVP": "Full RVP",
            "GroundValueLimit": 50000,
            "GroundValueLimiteTailPrePaid": 100000,
            "GroundZone": "South     ",
            "IsError": false,
            "PinCode": "500062",
            "PincodeDescription": "DR.A.S.RAO NAGAR",
            "RVPEmbargo": "Full RVP",
            "Region": "SOUTH1",
            "RemoteApex": "NO",
            "RemoteGround": "NO",
            "ServiceCenterCode": "NMT",
            "State": "TELANGANA",
            "TCLDriveWayZone": "A",
            "TCLServiceInbound": "Yes",
            "TCLServiceOutbound": "Yes",
            "eTailCODAirInbound": "Yes",
            "eTailCODAirOutbound": "Yes",
            "eTailCODGroundInbound": "Yes",
            "eTailCODGroundOutbound": "Yes",
            "eTailExpressCODAirInbound": "Yes",
            "eTailExpressCODAirOutbound": "Yes",
            "eTailExpressPrePaidAirInbound": "Yes",
            "eTailExpressPrePaidAirOutound": "Yes",
            "eTailPrePaidAirInbound": "Yes",
            "eTailPrePaidAirOutound": "Yes",
            "eTailPrePaidGroundInbound": "Yes",
            "eTailPrePaidGroundOutbound": "Yes"
        }
    }
    stub_request(:post, "https://netconnect.bluedart.com/API-QA/Ver1.10/Demo/ShippingAPI/Finder/ServiceFinderQuery.svc/rest/GetServicesforPincode").
         with(
           body: "{\"pinCode\":\"500062\",\"profile\":{\"Api_type\":\"S\",\"LicenceKey\":\"lk\",\"LoginID\":\"ld\",\"Version\":\"1.8\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json; charset="utf-8"',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: response_body.to_json, headers: {'Content-Type': 'application/json; charset="utf-8"'})
    b = Bluedart::PincodeService.new(details)
    resp = b.response_json
    is_cod_serviceable = resp[:content][:e_tail_cod_air_inbound] == "Yes"
    is_prepaid_serviceable = resp[:content][:e_tail_pre_paid_air_inbound] == "Yes"
    expect(is_cod_serviceable).to be(true)
    expect(is_prepaid_serviceable).to be(true)
  end
end