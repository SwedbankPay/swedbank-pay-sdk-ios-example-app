
/// Part of the `PurchaseData` so must conform to Encodable protocol too
struct PurchaseItem: Encodable {
    var itemId: String
    var quantity: Int
    var price: Int
    var vat: Int
}
