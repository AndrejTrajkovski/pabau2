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
                XButton(onTouch: onXBtnTap).padding(EdgeInsets(top: 30, leading: 24, bottom: 0, trailing: 0))
				ScrollView(showsIndicators: false) {
					content
				}
                .padding([.leading, .trailing, .bottom], UIDevice.current.userInterfaceIdiom == .pad ? 56 : 16)
			}
			.edgesIgnoringSafeArea(.top)
			.navigationBarHidden(true)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
