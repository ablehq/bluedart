require 'spec_helper'

describe "Cancel awb json communication mode" do
  it 'should cancel awb' do
    details ={
      awbno: "81201390244",
      comms_mode: "json",
      mode: "development",
      debug: true,
      creds: {
        license_key: "lk",
        login_id: "ld"
      }
    }
    response_body = {
      "CancelWaybillResult": {
          "AWBNo": "81201390244",
          "CCRCRDREF": nil,
          "IsError": false,
          "Status": [
              {
                  "StatusCode": "Valid",
                  "StatusInformation": "Your registered shipment 81201390244 has been cancelled successfully"
              }
          ]
      }
    }    
    stub_request(:post, "https://netconnect.bluedart.com/API-QA/Ver1.10/Demo/ShippingAPI/WayBill/WayBillGeneration.svc/rest/CancelWaybill").
         with(
           body: "{\"Request\":{\"AWBNo\":\"81201390244\"},\"Profile\":{\"Api_type\":\"S\",\"LicenceKey\":\"lk\",\"LoginID\":\"ld\",\"Version\":\"1.8\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json; charset="utf-8"',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: response_body.to_json, headers: {'Content-Type': 'application/json; charset="utf-8"'})
    b = Bluedart::CancelAwb.new(details)
    resp = b.response_json
    expect(resp[:content][:awb_no]).to eq("81201390244")
  end
end