import UIKit

extension UIColor {
	
	func makeLighter() -> UIColor {
		var hue: CGFloat = 0
		var sat: CGFloat = 0
		var bri: CGFloat = 0
		var alpha: CGFloat = 0
		if self.getHue(&hue,
									 saturation: &sat,
									 brightness: &bri,
									 alpha: &alpha) {
			return UIColor.init(hue: hue,
													saturation: sat,
													brightness: bri * 0.9,
													alpha: alpha)
		} else {
			return self
		}
	}
}
