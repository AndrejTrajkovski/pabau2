import UIKit

extension UIColor {
	
	public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
		self.init(
			red: CGFloat(red) / 255.0,
			green: CGFloat(green) / 255.0,
			blue: CGFloat(blue) / 255.0,
			alpha: alpha
		)
	}
	// Get UIColor by hex
	public convenience init(hex: Int, alpha: CGFloat = 1.0) {
		self.init(
			red: (hex >> 16) & 0xFF,
			green: (hex >> 8) & 0xFF,
			blue: hex & 0xFF,
			alpha: alpha
		)
	}
}
