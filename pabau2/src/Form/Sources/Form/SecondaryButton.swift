import SwiftUI
import Util

public struct SecondaryButton: View {

	let btnTxt: String
	let action: () -> Void

	public init (_ btnTxt: String, _ action: @escaping () -> Void) {
		self.btnTxt = btnTxt
		self.action = action
	}

	public var body: some View {
		Button(action: action,
					 label: {
			Text(btnTxt)
				.font(Font.system(size: 16.0, weight: .bold))
				.frame(minWidth: 0, maxWidth: .infinity)
		}).buttonStyle(PathwayWhiteButtonStyle())
			.cornerRadius(4)
			.shadow(color: .bigBtnShadow2,
							radius: 8.0,
							y: 2)
	}
}

public struct PathwayWhiteButtonStyle: ButtonStyle {
	public init () {}
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.black)
			.background(Color.white)
	}
}
