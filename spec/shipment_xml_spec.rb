require 'spec_helper'

describe "Generate shipment in xml communication mode" do
  it 'should generate label using soap xml communication' do
    details ={
      shipper_details: {
        customer_code: "3212",
        license_key: "lk",
        login_id: "ld",
        sender: "sender_123",
        vendor_code: "cust_123",
        customer_name: "Good Customer",
        address: "some address string.",
        customer_pincode: "500094",
        customer_telephone: "",
        customer_mobile: "919999999999",
        customer_email_id: "",
        isToPayCustomer: false,
        origin_area: "HYD"
      },
      consignee_details: {
        consignee_name: "Cosnginee C",
        address: "Long consigneee address", 
        consignee_pincode: "500062", 
        consignee_telephone:"",
        consignee_mobile:"919999999998",
        consignee_attention:"Attention Name"
      },
      services: {
        piece_count: 1,
        actual_weight: 0.5,
        pack_type: "",
        invoice_no: "",
        special_instruction: "",
        declared_value: 950,
        credit_reference_no: "112-1",
        dimensions: [
          {
            count: 1,
            height: 5,
            width: 10,
            breadth: 10,
          }
        ],
        pickup_date: "2023-06-13",
        pickup_time: "1530",
        commodities: ["BTTWTx1"],
        product_type: "Dutiables",
        collactable_amount: 0,
        product_code: "A",
        sub_product_code: "P",
        p_d_f_output_not_required: true,
        register_pickup: true
      },
      mode: "development",
      debug: true,
      creds: {
        license_key: "lk",
        login_id: "ld"
      }
    }
    expected_body = '
    <env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope" xmlns:ns1="http://tempuri.org/" xmlns:ns2="http://schemas.datacontract.org/2004/07/SAPI.Entities.Admin" xmlns:ns3="http://www.w3.org/2005/08/addressing" xmlns:ns4="http://schemas.datacontract.org/2004/07/SAPI.Entities.WayBillGeneration" xmlns:ns5="http://schemas.datacontract.org/2004/07/SAPI.Entities.Pickup">
         <env:Header>
           <ns3:Action env:mustUnderstand="true">http://tempuri.org/IWayBillGeneration/GenerateWayBill</ns3:Action>
         </env:Header>
         <env:Body>
          <Error>true</Error>
          <ErrorMessage>something</ErrorMessage>
         </env:Body>
    </env:Envelope>     
    '
    stub_request(:post, "https://netconnect.bluedart.com/Ver1.10/Demo/ShippingAPI/WayBill/WayBillGeneration.svc").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns1=\"http://tempuri.org/\" xmlns:ns2=\"http://schemas.datacontract.org/2004/07/SAPI.Entities.Admin\" xmlns:ns3=\"http://www.w3.org/2005/08/addressing\" xmlns:ns4=\"http://schemas.datacontract.org/2004/07/SAPI.Entities.WayBillGeneration\" xmlns:ns5=\"http://schemas.datacontract.org/2004/07/SAPI.Entities.Pickup\">\n  <env:Header>\n    <ns3:Action env:mustUnderstand=\"true\">http://tempuri.org/IWayBillGeneration/GenerateWayBill</ns3:Action>\n  </env:Header>\n  <env:Body>\n    <ns1:GenerateWayBill>\n      <ns1:Request>\n        <ns4:Consignee>\n          <ns4:ConsigneeAddress1>Long consigneee address</ns4:ConsigneeAddress1>\n          <ns4:ConsigneeAddress2/>\n          <ns4:ConsigneeAddress3/>\n          <ns4:ConsigneeAttention>Attention Name</ns4:ConsigneeAttention>\n          <ns4:ConsigneeMobile>919999999998</ns4:ConsigneeMobile>\n          <ns4:ConsigneeName>Cosnginee C</ns4:ConsigneeName>\n          <ns4:ConsigneePincode>500062</ns4:ConsigneePincode>\n          <ns4:ConsigneeTelephone/>\n        </ns4:Consignee>\n        <ns4:Services>\n          <ns4:ActualWeight>0.5</ns4:ActualWeight>\n          <ns4:CollectableAmount>0</ns4:CollectableAmount>\n          <ns4:Commodity>\n            <ns4:CommodityDetail1>BTTWTx1</ns4:CommodityDetail1>\n          </ns4:Commodity>\n          <ns4:CreditReferenceNo>112-1</ns4:CreditReferenceNo>\n          <ns4:DeclaredValue>950</ns4:DeclaredValue>\n          <ns4:Dimensions>\n            <ns4:Dimension>\n              <ns4:Breadth>10</ns4:Breadth>\n              <ns4:Height>5</ns4:Height>\n              <ns4:Length/>\n              <ns4:Count>1</ns4:Count>\n            </ns4:Dimension>\n          </ns4:Dimensions>\n          <ns4:InvoiceNo/>\n          <ns4:PackType/>\n          <ns4:PickupDate>2023-06-13</ns4:PickupDate>\n          <ns4:PickupTime>1530</ns4:PickupTime>\n          <ns4:PieceCount>1</ns4:PieceCount>\n          <ns4:ProductCode>A</ns4:ProductCode>\n          <ns4:RegisterPickup>true</ns4:RegisterPickup>\n          <ns4:ProductType>Dutiables</ns4:ProductType>\n          <ns4:SubProductCode>P</ns4:SubProductCode>\n          <ns4:SpecialInstruction/>\n          <ns4:PDFOutputNotRequired>true</ns4:PDFOutputNotRequired>\n        </ns4:Services>\n        <ns4:Shipper>\n          <ns4:CustomerAddress1>some address string.</ns4:CustomerAddress1>\n          <ns4:CustomerAddress2/>\n          <ns4:CustomerAddress3/>\n          <ns4:CustomerCode>3212</ns4:CustomerCode>\n          <ns4:CustomerEmailID/>\n          <ns4:CustomerMobile>919999999999</ns4:CustomerMobile>\n          <ns4:CustomerName>Good Customer</ns4:CustomerName>\n          <ns4:CustomerPincode>500094</ns4:CustomerPincode>\n          <ns4:CustomerTelephone/>\n          <ns4:IsToPayCustomer>false</ns4:IsToPayCustomer>\n          <ns4:OriginArea>HYD</ns4:OriginArea>\n          <ns4:Sender>sender_123</ns4:Sender>\n          <ns4:VendorCode>cust_123</ns4:VendorCode>\n        </ns4:Shipper>\n      </ns1:Request>\n      <ns1:Profile>\n        <ns2:Api_type>S</ns2:Api_type>\n        <ns2:LicenceKey>lk</ns2:LicenceKey>\n        <ns2:LoginID>ld</ns2:LoginID>\n        <ns2:Version>1.3</ns2:Version>\n      </ns1:Profile>\n    </ns1:GenerateWayBill>\n  </env:Body>\n</env:Envelope>\n",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/soap+xml; charset="utf-8"',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: expected_body, headers: {})
    b = Bluedart::Shipment.new(details)
    resp = b.response
    expect(resp[:error]).to be(true)
  end
end