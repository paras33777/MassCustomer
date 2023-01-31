
import Foundation

struct OrderInfo: Codable {

    let orderId: String?
    let totalAmount: String?
    let GrandTotal:String?
    let taxAmount:String?
    let paymentMethod: String?
    let paymentId: String?
    let orderdate: String?
    let paymentStatus: String?
    let invoiceLink: String?
    let reason: String?
    let subStatus:String?
    let cartMainId : String?
    let orderStatus : String?
    let productList: [Productlist]?
    let taxData: [TaxData]?
  
    private enum CodingKeys: String, CodingKey {
        case orderId = "orderId"
        case totalAmount = "totalAmount"
        case paymentMethod = "paymentMethod"
        case paymentId = "payment_id"
        case orderdate = "orderdate"
        case paymentStatus = "payment_status"
        case invoiceLink = "invoice_link"
        case productList = "productlist"
        case cartMainId = "cart_main_id"
        case orderStatus = "orderStatus"
        case reason = "reason"
        case subStatus = "sub_status"
        case taxData = "taxData"
        case taxAmount = "taxAmount"
        case GrandTotal = "GrandTotal"
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decodeIfPresent(String.self, forKey: .orderId)
        do {
            let idInt = try values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0
            totalAmount = String(idInt )
        } catch DecodingError.typeMismatch {
            totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount) ?? ""
        }
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        paymentId = try values.decodeIfPresent(String.self, forKey: .paymentId)
        orderdate = try values.decodeIfPresent(String.self, forKey: .orderdate)
        paymentStatus = try values.decodeIfPresent(String.self, forKey: .paymentStatus)
        invoiceLink = try values.decodeIfPresent(String.self, forKey: .invoiceLink)
        productList = try values.decodeIfPresent([Productlist].self, forKey: .productList)
        cartMainId = try values.decodeIfPresent(String.self, forKey: .cartMainId)
        orderStatus = try values.decodeIfPresent(String.self, forKey: .orderStatus)
        reason = try values.decodeIfPresent(String.self, forKey: .reason)
        subStatus = try values.decodeIfPresent(String.self, forKey: .subStatus)
        taxData = try values.decodeIfPresent([TaxData].self, forKey: .taxData)
        taxAmount = try values.decodeIfPresent(String.self, forKey: .taxAmount)
        GrandTotal = try values.decodeIfPresent(String.self, forKey: .GrandTotal)
        
    }
}
