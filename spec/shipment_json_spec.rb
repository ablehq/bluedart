require 'spec_helper'

describe "Generate shipment in json communication mode" do
  it 'should generate label using rest communication' do
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
            length: 10,
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
      comms_mode: "json",
      mode: "development",
      debug: true,
      creds: {
        license_key: "lk",
        login_id: "ld"
      }
    }
    response_body = {
        "GenerateWayBillResult": {
            "AWBNo": "81201393232",
            "AWBPrintContent": nil,
            "AvailableAmountForBooking": 0,
            "AvailableBalance": 0,
            "CCRCRDREF": "A5456221071-1-1147",
            "ClusterCode": "NME",
            "DestinationArea": "HYD",
            "DestinationLocation": "NME",
            "IsError": false,
            "IsErrorInPU": false,
            "ShipmentPickupDate": "/Date(1687285800000+0530)/",
            "Status": [
                {
                    "StatusCode": "Valid",
                    "StatusInformation": "Waybill Generation Sucessful"
                },
                {
                    "StatusCode": "Pickup Registration:InsertFailure",
                    "StatusInformation": "PickupIsAlreadyRegister"
                }
            ],
            "TokenNumber": "2240441DEMO",
            "TransactionAmount": 0
        }
    }
    stub_request(:post, "https://netconnect.bluedart.com/API-QA/Ver1.10/Demo/ShippingAPI/WayBill/WayBillGeneration.svc/rest/GenerateWayBill").
         with(
           body: "{\"Request\":{\"Consignee\":{\"ConsigneeAddress1\":\"Long consigneee address\",\"ConsigneeAddress2\":null,\"ConsigneeAddress3\":null,\"ConsigneeAttention\":\"Attention Name\",\"ConsigneeMobile\":\"919999999998\",\"ConsigneeName\":\"Cosnginee C\",\"ConsigneePincode\":\"500062\",\"ConsigneeTelephone\":\"\"},\"Services\":{\"ActualWeight\":0.5,\"CollectableAmount\":0,\"Commodity\":{\"CommodityDetail1\":\"BTTWTx1\"},\"CreditReferenceNo\":\"112-1\",\"DeclaredValue\":950,\"Dimensions\":[{\"Count\":1,\"Height\":5,\"Length\":10,\"Breadth\":10}],\"InvoiceNo\":\"\",\"PackType\":\"\",\"PickupDate\":\"/Date(1686650400000)/\",\"PickupTime\":\"1530\",\"PieceCount\":1,\"ProductCode\":\"A\",\"RegisterPickup\":true,\"ProductType\":1,\"SubProductCode\":\"P\",\"SpecialInstruction\":\"\",\"PDFOutputNotRequired\":true},\"Shipper\":{\"CustomerAddress1\":\"some address string.\",\"CustomerAddress2\":null,\"CustomerAddress3\":null,\"CustomerCode\":\"3212\",\"CustomerEmailID\":\"\",\"CustomerMobile\":\"919999999999\",\"CustomerName\":\"Good Customer\",\"CustomerPincode\":\"500094\",\"CustomerTelephone\":\"\",\"IsToPayCustomer\":false,\"OriginArea\":\"HYD\",\"Sender\":\"sender_123\",\"VendorCode\":\"cust_123\"}},\"Profile\":{\"Api_type\":\"S\",\"LicenceKey\":\"lk\",\"LoginID\":\"ld\",\"Version\":\"1.8\"}}",
           headers: {
       	  'Content-Type': 'application/json; charset="utf-8"'
           }).
         to_return(status: 200, body: response_body.to_json, headers: {'Content-Type': 'application/json; charset="utf-8"'})
    b = Bluedart::Shipment.new(details)
    resp = b.response_json
    expect(resp[:content][:awb_no]).to eq("81201393232")
  end
end