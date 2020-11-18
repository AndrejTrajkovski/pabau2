import SwiftUI
#if !os(macOS)
public extension Color {
	init(hex: String, alpha: CGFloat = 1.0) {
		self.init(UIColor.init(hex: hex, alpha: alpha))
	}
}

extension UIColor {
	convenience init(hex: String, alpha: CGFloat = 1.0) {
		var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

		if hexFormatted.hasPrefix("#") {
			hexFormatted = String(hexFormatted.dropFirst())
		}

		assert(hexFormatted.count == 6, "Invalid hex code used.")

		var rgbValue: UInt64 = 0
		Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

		self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
							green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
							blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
							alpha: alpha)
	}
}

public extension Color {
	static let main = Color.init(red: 0, green: 122, blue: 255)
	static let gradient = Color.init(red: 121, green: 191, blue: 246)
	static let gray1 = Color.init(red: 49, green: 49, blue: 49)
	static let gray2 = Color.init(red: 70, green: 70, blue: 70)
	static let gray3 = Color.init(red: 158, green: 158, blue: 158)
	static let gray838383 = Color.init(red: 83/255, green: 83/255, blue: 83/255)
	static let gray140 = Color.init(red: 140/255, green: 140/255, blue: 140/255)
	static let grey155 = Color.init(red: 155/255, green: 155/255, blue: 155/255)
	static let grey216 = Color.init(red: 216/255, green: 216/255, blue: 216/255)
	static let gray192 = Color.init(red: 192/255, green: 192/255, blue: 192/255)
	static let gray249 = Color.init(red: 249/255, green: 249/255, blue: 249/255)
	static let gray142 = Color.init(red: 142/255, green: 142/255, blue: 142/255)
	static let gray184 = Color.init(red: 184/255, green: 184/255, blue: 184/255)

	static let black42 = Color.init(red: 42/255, green: 42/255, blue: 42/255)

	static let validationFail = Color.init(red: 1, green: 0, blue: 25/255)

	static let textFieldAndTextLabel = Color.init(red: 22/255, green: 31/255, blue: 61/255)

	static let textFieldBottomLine = Color.init(red: 29/255, green: 29/255, blue: 38/255)

	static let lightBlueGrey = Color.init(red: 199/255, green: 199/255, blue: 204/255 )

	static let weirdGreen = Color.init(red: 76/255, green: 217/255, blue: 100/255 )

	static let paleGrey = Color.init(red: 239/255, green: 239/255, blue: 244/255 )

	static let orangeyRed = Color.init(red: 1, green: 59/255, blue: 48/255 )

	static let paleLilac = Color.init(red: 229/255, green: 229/255, blue: 234/255 )

	static let veryLightPink30 = Color.init(white: 216).opacity(0.3)

	static let blackTwo = Color.init(white: 49/255)

	static let deepSkyBlue = Color.init(red: 0, green: 122/255, blue: 1)
	static let blue2 = Color.init(red: 14/255, green: 122/255, blue: 1)
	static let employeeBg = Color.init(red: 242/255, green: 242/255, blue: 247/255)

	static let heartRed = Color.init(red: 248/255, green: 92/255, blue: 92/255)

	static let bigBtnShadow1 = Color(hex: "91C6FF")

	static let bigBtnShadow2 = Color.init(red: 196/255, green: 196/255, blue: 196/255).opacity(0.5)

	static let employeeShadow = Color.init(red: 196/255, green: 196/255, blue: 196/255).opacity(0.55)

	static let checkInGradient1 = Color.init(red: 0/255, green: 178/255, blue: 255/255)

	static let checkInSubtitle = Color(hex: "C3E0FF")

	static let checkBoxGray = Color(hex: "C0C0C0")

	static let arrowGray = Color(hex: "D1D1D6")
	
	static let cameraImages = Color(hex: "B8B8B8")
	
	static let clientCardNeutral = Color(hex: "8C8C8C")
}
#endif
