
/// Example purchase data; *must* conform to Encodable protocol
struct PurchaseData: Encodable {
    var basketId: String
    var currency: String
    var languageCode: String
    var items: [PurchaseItem]
}
