import SwiftUI

// MARK: - String-based Hex Initializer
// Required by MapiService which passes hex colors as strings (e.g. "121212")
// This supplements the UInt-based initializer in Color+Boozt.swift

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        self.init(
            .sRGB,
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            opacity: 1.0
        )
    }
}
