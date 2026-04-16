import Foundation
import SwiftUI

// MARK: - Product Item

/// Shared product model used by both MapiService API responses and mock data.
/// Both the search and navigation endpoints map to this type via their `toProductItem()` methods.
struct ProductItem: Identifiable, Hashable {
    let id = UUID()
    let brand: String
    let name: String
    let price: Int              // Display price in DKK (original price if on sale)
    let salePrice: Int?         // Discounted price in DKK (nil if not on sale)
    let deal: String?           // Deal badge text, e.g. "35% Deal"
    let isPremium: Bool
    let imageURL: String        // Full URL to product image via booztcdn.com
    let swatchColors: [Color]   // Approximate color swatches derived from color name
    let sizes: [String]         // Available sizes, e.g. ["S", "M", "L"] or ["38", "39", "40"]

    /// Whether this product is currently on sale
    var isOnSale: Bool { salePrice != nil }

    /// Discount percentage (e.g. 30 for -30%), nil if not on sale
    var discountPercentage: Int? {
        guard let sale = salePrice, price > 0 else { return nil }
        return Int(round(Double(price - sale) / Double(price) * 100))
    }

    /// Formatted display price (e.g. "1.299 DKK")
    var formattedPrice: String {
        formatDKK(price)
    }

    /// Formatted sale price (e.g. "899 DKK"), nil if not on sale
    var formattedSalePrice: String? {
        guard let sale = salePrice else { return nil }
        return formatDKK(sale)
    }

    private func formatDKK(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) DKK"
    }

    // MARK: - Hashable (exclude id so two items with same data match)

    static func == (lhs: ProductItem, rhs: ProductItem) -> Bool {
        lhs.brand == rhs.brand && lhs.name == rhs.name && lhs.imageURL == rhs.imageURL
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(brand)
        hasher.combine(name)
        hasher.combine(imageURL)
    }
}

// MARK: - Mock Data

extension ProductItem {
    static let mock = ProductItem(
        brand: "GANT",
        name: "Sneaker Mc Julien – Herresko",
        price: 1299,
        salePrice: 899,
        deal: "-30%",
        isPremium: false,
        imageURL: "https://image-resizing.booztcdn.com/gant/gant_28633g771_g10_f.webp",
        swatchColors: [.white, .black, Color(hex: "1A2744")],
        sizes: ["36", "37", "38", "39", "40", "41", "42", "43", "44", "45"]
    )

    static let mockNoSale = ProductItem(
        brand: "Desigual",
        name: "TS_ESTOCOLMO - T-shirts",
        price: 299,
        salePrice: nil,
        deal: nil,
        isPremium: false,
        imageURL: "",
        swatchColors: [Color(hex: "1580EB")],
        sizes: ["XS", "S", "M", "L", "XL"]
    )

    static let mockProducts: [ProductItem] = [
        .mock,
        .mockNoSale,
        ProductItem(brand: "Ralph Lauren", name: "Slim Fit Oxford Skjorte", price: 899, salePrice: nil, deal: nil, isPremium: false, imageURL: "", swatchColors: [.white, Color(hex: "1580EB")], sizes: ["S", "M", "L", "XL"]),
        ProductItem(brand: "Calvin Klein", name: "Modern Cotton Bralette", price: 349, salePrice: 249, deal: "-29%", isPremium: false, imageURL: "", swatchColors: [Color(hex: "121212")], sizes: ["XS", "S", "M", "L"]),
        ProductItem(brand: "ROTATE", name: "Embellished Midi Kjole", price: 2499, salePrice: nil, deal: nil, isPremium: true, imageURL: "", swatchColors: [Color(hex: "121212"), Color(hex: "E0001A")], sizes: ["34", "36", "38", "40"]),
        ProductItem(brand: "Malina", name: "Amara Cardigan", price: 1899, salePrice: 1329, deal: "-30%", isPremium: true, imageURL: "", swatchColors: [Color(hex: "E8DCC8")], sizes: ["XS", "S", "M"]),
    ]
}
