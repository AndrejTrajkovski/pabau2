import SwiftUI
import Util

public extension View {
	func addEventWrapper(onXBtnTap: @escaping () -> Void) -> some View {
		self.modifier(AddEventModifier(onXBtnTap: onXBtnTap))
	}
}

public struct AddEventModifier: ViewModifier {
	let onXBtnTap: () -> Void
	public func body(content: Content) -> some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 0) {
				XButton(onTouch: onXBtnTap).padding([.leading, .top], 24)
				ScrollView {
					content
				}
				.padding([.leading, .trailing, .bottom], 56)
			}
			.edgesIgnoringSafeArea(.top)
			.navigationBarHidden(true)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
