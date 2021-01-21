import SwiftUI

struct InjectablesToolNumber: View {

	let number: Double
	let color: Color
	let hasActiveInjection: Bool

	var body: some View {
		Group {
			if hasActiveInjection {
				InjectableMarkerCircle(increment: String(number),
															 color: color,
															 isActive: true)
			} else {
				Text(String(number)).font(.regular17)
			}
		}.frame(width: 50, height: 50)
	}
}
