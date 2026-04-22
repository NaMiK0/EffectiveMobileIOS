import UIKit

enum AppColors {
    static let background      = UIColor(hex: "0A0A0A")
    static let surface         = UIColor(hex: "141414")
    static let surfaceElevated = UIColor(hex: "1E1E1E")
    static let accent          = UIColor(hex: "30D158")
    static let accentDim       = UIColor(hex: "30D158").withAlphaComponent(0.15)
    static let textPrimary     = UIColor.white
    static let textSecondary   = UIColor(hex: "8E8E93")
    static let textDisabled    = UIColor(hex: "3A3A3C")
    static let separator       = UIColor(hex: "2C2C2E")
    static let destructive     = UIColor(hex: "FF453A")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8)  & 0xFF) / 255
        let b = CGFloat(value         & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
