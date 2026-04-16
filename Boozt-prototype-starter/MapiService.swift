//
//  MapiService.swift
//  Chat AI
//
//  Created by Justin-JDAN on 26/03/2026.
//

import Foundation
import SwiftUI

// MARK: - Response Models

struct MapiSearchResponse: Decodable {
    let type: String?
    let navigationName: String?
    let breadcrumbs: [String]?
    let listingData: [MapiListingItem]?
    let categories: [MapiCategory]?

    enum CodingKeys: String, CodingKey {
        case type
        case navigationName = "navigation_name"
        case breadcrumbs
        case listingData    = "listing_data"
        case categories
    }
}

struct MapiCategory: Decodable {
    let navigationId: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case navigationId = "navigation_id"
        case title
    }
}

struct MapiListingItem: Decodable {
    let type: String?       // "PRODUCT", "BANNER", etc.
    let data: MapiProductData?
}

struct MapiProductData: Decodable {
    let sku: String?
    let brandName: String?
    let brandSlug: String?
    let productName: String?
    let actualPrice: String?
    let basePrice: String?
    let saleActive: String?
    let ratio: String?
    let filename: String?
    let availableSizes: String?
    let availableColorCodes: String?
    let availableColorNames: String?

    enum CodingKeys: String, CodingKey {
        case sku
        case brandName          = "brand_name"
        case brandSlug          = "brand_slug"
        case productName        = "product_name"
        case actualPrice        = "actual_price"
        case basePrice          = "base_price"
        case saleActive         = "sale_active"
        case ratio
        case filename
        case availableSizes     = "available_sizes"
        case availableColorCodes = "available_color_codes"
        case availableColorNames = "available_color_names"
    }

    func toProductItem() -> ProductItem {
        // Image URL
        let imageURL: String
        if let slug = brandSlug, let file = filename, !slug.isEmpty, !file.isEmpty {
            imageURL = "https://image-resizing.booztcdn.com/\(slug)/\(file)"
        } else {
            imageURL = ""
        }

        // Prices (API returns strings like "1699.000")
        let currentPrice = Int(Double(actualPrice ?? "0") ?? 0)
        let originalPrice = Int(Double(basePrice ?? "0") ?? 0)
        let onSale = saleActive == "1" || (Double(ratio ?? "0") ?? 0) > 0
        let salePrice: Int? = onSale && currentPrice < originalPrice ? currentPrice : nil
        let displayPrice = onSale ? originalPrice : currentPrice

        // Sizes (comma-separated string)
        let sizes = availableSizes?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            ?? []

        // Approximate swatch color from color name
        let swatchColors = colorsFromName(availableColorNames)

        return ProductItem(
            brand: brandName ?? "Unknown",
            name: productName ?? "",
            price: displayPrice,
            salePrice: salePrice,
            deal: nil,
            isPremium: false,
            imageURL: imageURL,
            swatchColors: swatchColors,
            sizes: sizes
        )
    }

    /// Maps Boozt color name strings to approximate SwiftUI colors.
    private func colorsFromName(_ names: String?) -> [Color] {
        guard let names = names, !names.isEmpty else { return [Color(hex: "121212")] }
        let lookup: [String: String] = [
            "BLACK": "121212", "WHITE": "FFFFFF", "GREY": "92949B", "GRAY": "92949B",
            "BROWN": "6B4C3B", "CAMEL": "C4A882", "BEIGE": "E8DCC8", "CREAM": "F5F0E8",
            "NAVY": "241D26",  "BLUE": "1580EB",  "RED": "E0001A",   "PINK": "FF4D8C",
            "GREEN": "33D973", "YELLOW": "FFD900", "ORANGE": "FF801A", "PURPLE": "8C33E5",
            "GOLD": "C9A84C",  "SILVER": "C0C0C0", "NUDE": "E8C9A0", "TAN": "D2A679",
        ]
        let upper = names.uppercased()
        for (keyword, hex) in lookup {
            if upper.contains(keyword) { return [Color(hex: hex)] }
        }
        return [Color(hex: "121212")]
    }
}

// MARK: - Navigation Products Models

struct NavigationProductsResponse: Decodable {
    let productCards: [NavigationProductCard]

    enum CodingKeys: String, CodingKey {
        case productCards = "product_cards"
    }
}

struct NavigationProductCard: Decodable {
    let id: Int
    let swatchId: Int?
    let swatchIds: [Int]?
    let colorName: String?
    let sizes: [String]?
    let prices: NavigationProductPrices?
    let media: [NavigationProductMedia]?
    let displayName: String?
    let productName: String?
    let brandName: String?
    let inStock: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case swatchId    = "swatch_id"
        case swatchIds   = "swatch_ids"
        case colorName   = "color_name"
        case sizes
        case prices
        case media
        case displayName = "display_name"
        case productName = "product_name"
        case brandName   = "brand_name"
        case inStock     = "in_stock"
    }

    func toProductItem() -> ProductItem {
        let imageURL = media?.first(where: { $0.isModel == true })?.url
            ?? media?.first?.url
            ?? ""

        let basePrice  = Int(Double(prices?.base?.price ?? "0") ?? 0)
        let saleAmount = Int(Double(prices?.sale?.price ?? "0") ?? 0)
        let salePrice: Int? = saleAmount > 0 && saleAmount < basePrice ? saleAmount : nil
        let displayPrice = salePrice != nil ? basePrice : basePrice

        let swatchColor = colorNameToHex(colorName)

        return ProductItem(
            brand:       brandName ?? "Unknown",
            name:        displayName ?? productName ?? "",
            price:       displayPrice,
            salePrice:   salePrice,
            deal:        nil,
            isPremium:   false,
            imageURL:    imageURL,
            swatchColors: [Color(hex: swatchColor)],
            sizes:       sizes ?? []
        )
    }

    private func colorNameToHex(_ name: String?) -> String {
        guard let name = name else { return "121212" }
        let upper = name.uppercased()
        let lookup: [String: String] = [
            "BLACK": "121212", "WHITE": "FFFFFF", "GREY": "92949B", "GRAY": "92949B",
            "BROWN": "6B4C3B", "CAMEL": "C4A882", "BEIGE": "E8DCC8", "CREAM": "F5F0E8",
            "NAVY": "1A2744",  "BLUE": "1580EB",  "RED": "E0001A",   "PINK": "FF4D8C",
            "GREEN": "33D973", "YELLOW": "FFD900", "ORANGE": "FF801A", "PURPLE": "8C33E5",
            "GOLD": "C9A84C",  "SILVER": "C0C0C0", "NUDE": "E8C9A0", "TAN": "D2A679",
        ]
        for (keyword, hex) in lookup {
            if upper.contains(keyword) { return hex }
        }
        return "121212"
    }
}

struct NavigationProductPrices: Decodable {
    let base: NavigationProductPrice?
    let sale: NavigationProductPrice?
}

struct NavigationProductPrice: Decodable {
    let price: String?
}

struct NavigationProductMedia: Decodable {
    let type: String?
    let url: String
    let isModel: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case isModel = "is_model"
    }
}

// MARK: - Auth Models

struct MapiLoginRequest: Encodable {
    let oauthProvider: String
    let accessToken: String
    let idToken: String
    let deviceToken: String?

    enum CodingKeys: String, CodingKey {
        case oauthProvider = "oauth_provider"
        case accessToken   = "access_token"
        case idToken       = "id_token"
        case deviceToken   = "device_token"
    }
}

struct MapiLoginResponse: Decodable {
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case expiresIn   = "expires_in"
    }
}

// MARK: - Errors

enum MapiError: LocalizedError {
    case authFailed
    case networkError
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .authFailed:         return "Authentication failed."
        case .networkError:       return "Network error. Check your connection."
        case .serverError(let c): return "Server error (\(c))."
        }
    }
}

// MARK: - Service

@MainActor
final class MapiService {

    static let shared = MapiService()

    private let baseURL  = "https://www.boozt.com"
    private let store    = "dk"
    private let language = "en"
    private let tokenKey = "mapi_auth_token"

    var authToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    // MARK: - Auth

    func login(
        oauthProvider: String = "apple",
        accessToken: String,
        idToken: String,
        deviceToken: String? = nil
    ) async throws {
        guard let url = URL(string: "\(baseURL)/mapi/login/oauth") else { throw MapiError.networkError }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        applyHeaders(to: &req)
        let body = MapiLoginRequest(oauthProvider: oauthProvider, accessToken: accessToken,
                                    idToken: idToken, deviceToken: deviceToken)
        req.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw MapiError.authFailed
        }
        let loginResponse = try JSONDecoder().decode(MapiLoginResponse.self, from: data)
        authToken = loginResponse.accessToken
    }

    // MARK: - Search

    func search(query: String, gender: String = "", department: String = "") async throws -> (message: String, products: [ProductItem]) {
        var components = URLComponents(string: "\(baseURL)/mapi/search/wf")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "page",   value: "1"),
            URLQueryItem(name: "limit",  value: "20"),
        ]
        if !gender.isEmpty     { queryItems.append(URLQueryItem(name: "gender",     value: gender)) }
        if !department.isEmpty { queryItems.append(URLQueryItem(name: "department", value: department)) }
        components?.queryItems = queryItems

        guard let url = components?.url else { throw MapiError.networkError }
        var req = URLRequest(url: url)
        applyHeaders(to: &req)

        print("🛍 MAPI search URL: \(url)")
        print("🛍 MAPI auth token: \(authToken ?? "nil")")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw MapiError.networkError }
        print("🛍 MAPI search status: \(http.statusCode)")
        if http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            print("🛍 MAPI error body: \(body.prefix(500))")
        }
        guard http.statusCode == 200 else { throw MapiError.serverError(http.statusCode) }

        var decoded = try JSONDecoder().decode(MapiSearchResponse.self, from: data)

        // If listing_data is empty, drill into the best matching sub-category
        if (decoded.listingData ?? []).isEmpty, let categories = decoded.categories, !categories.isEmpty {
            let queryWords = query.lowercased().components(separatedBy: " ")
            let best = categories.first(where: { cat in
                let title = (cat.title ?? "").lowercased()
                return queryWords.contains { title.contains($0) }
            }) ?? categories.first

            if let navId = best?.navigationId {
                var subComponents = URLComponents(string: "\(baseURL)/mapi/search/wf")
                subComponents?.queryItems = [
                    URLQueryItem(name: "navigation_id", value: "\(navId)"),
                    URLQueryItem(name: "page",  value: "1"),
                    URLQueryItem(name: "limit", value: "20"),
                ]
                if let subURL = subComponents?.url {
                    var subReq = URLRequest(url: subURL)
                    applyHeaders(to: &subReq)
                    if let (subData, _) = try? await URLSession.shared.data(for: subReq) {
                        decoded = (try? JSONDecoder().decode(MapiSearchResponse.self, from: subData)) ?? decoded
                    }
                }
            }
        }

        // Map query color words to all known synonyms (incl. international)
        let colorSynonyms: [String: [String]] = [
            "black":  ["black", "noir", "nero", "schwarz", "zwart", "sort", "svart"],
            "white":  ["white", "blanc", "bianco", "weiß", "wit", "hvid"],
            "red":    ["red", "rouge", "rosso", "rot", "rood", "rød"],
            "blue":   ["blue", "bleu", "azzurro", "blau", "blauw", "blå"],
            "green":  ["green", "vert", "verde", "grün", "groen", "grøn"],
            "brown":  ["brown", "marron", "braun", "bruin", "brun"],
            "grey":   ["grey", "gray", "gris", "grau", "grijs", "grå"],
            "beige":  ["beige", "sand", "camel", "nude", "tan", "cream"],
            "navy":   ["navy", "marine", "dunkelblau"],
            "pink":   ["pink", "rose", "rosa"],
        ]

        let queryLower = query.lowercased()
        let matchSynonyms: [String] = colorSynonyms
            .filter { queryLower.contains($0.key) }
            .flatMap { $0.value }

        let allProducts = (decoded.listingData ?? [])
            .filter { $0.type == "PRODUCT" }
            .compactMap { $0.data }

        // Debug: print first 3 products
        allProducts.prefix(3).forEach { p in
            print("🛍 brand=\(p.brandName ?? "-") name=\(p.productName ?? "-") color=\(p.availableColorNames ?? "-") slug=\(p.brandSlug ?? "-") file=\(p.filename ?? "-")")
        }

        let colorFiltered = matchSynonyms.isEmpty ? allProducts : allProducts.filter { product in
            let colorName = (product.availableColorNames ?? "").lowercased()
            return matchSynonyms.contains { colorName.contains($0) }
        }

        // Fall back to unfiltered if color filter removes everything
        let source = colorFiltered.isEmpty ? allProducts : colorFiltered

        let products = source
            .map { $0.toProductItem() }
            .prefix(6)
            .map { $0 }

        let message = "Here are some results for \"\(query)\"."

        return (message: message, products: products)
    }

    // MARK: - Navigation Products

    /// Fetches products for a navigation category ID.
    /// Pass `swatchId` to filter by colour (e.g. 1012 = black). Filtering is done client-side.
    func fetchProducts(navigationId: Int, swatchId: Int? = nil, limit: Int = 20) async throws -> [ProductItem] {
        var components = URLComponents(string: "\(baseURL)/\(store)/\(language)/api/navigation/\(navigationId)/products")
        components?.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        guard let url = components?.url else { throw MapiError.networkError }

        var req = URLRequest(url: url)
        applyHeaders(to: &req)

        print("🛍 MAPI fetchProducts URL: \(url)")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw MapiError.networkError }
        guard http.statusCode == 200 else { throw MapiError.serverError(http.statusCode) }

        let decoded = try JSONDecoder().decode(NavigationProductsResponse.self, from: data)

        let cards = swatchId != nil
            ? decoded.productCards.filter { card in
                card.swatchId == swatchId ||
                (card.swatchIds ?? []).contains(swatchId!)
              }
            : decoded.productCards

        return cards
            .filter { $0.inStock != false }
            .prefix(6)
            .map { $0.toProductItem() }
    }

    // MARK: - Shared headers

    private func applyHeaders(to req: inout URLRequest) {
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(store,      forHTTPHeaderField: "X-Boozt-Store")
        req.setValue(language,   forHTTPHeaderField: "X-Boozt-Language")
        req.setValue("20221204", forHTTPHeaderField: "X-API-Version2")
        req.setValue("Boozt iPadOS/v7.22.0; 26.2; iPad", forHTTPHeaderField: "User-Agent")
        req.setValue("",         forHTTPHeaderField: "X-Features")
        if let token = authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
