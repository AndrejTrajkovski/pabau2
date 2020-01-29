import SwiftUI

struct BigButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.white)
			.background(Color.accentColor)
	}
}
