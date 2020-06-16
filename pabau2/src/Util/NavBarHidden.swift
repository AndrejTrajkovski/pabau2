import SwiftUI

public struct NavBarHidden: ViewModifier {
	let hideNavBar: Bool
	let title: String
	public func body(content: Content) -> some View {
		content
			.navigationBarTitle(hideNavBar ? Text("") : Text(title), displayMode: .inline)
			.navigationBarHidden(hideNavBar)
			.navigationBarBackButtonHidden(hideNavBar)
	}
}

public extension View {
	func hideNavBar(_ hideNavBar: Bool, _ title: String = "") -> some View {
		self.modifier(NavBarHidden(hideNavBar: hideNavBar, title: title))
	}
}
