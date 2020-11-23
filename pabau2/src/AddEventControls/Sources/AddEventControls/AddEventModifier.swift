import SwiftUI
import Util

public extension View {
	func addEventWrapper(title: String,
										onXBtnTap: @escaping () -> Void) -> some View {
		self.modifier(AddEventModifier(title: title, onXBtnTap: onXBtnTap))
	}
}

public struct AddEventModifier: ViewModifier {
	let title: String
	let onXBtnTap: () -> Void
	public func body(content: Content) -> some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 24) {
					Text(title).font(.semibold24).frame(maxWidth: .infinity, alignment: .leading)
					content
				}.padding([.leading, .trailing], 56)
			}
			.navigationBarItems(leading: XButton(onTouch: onXBtnTap))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
