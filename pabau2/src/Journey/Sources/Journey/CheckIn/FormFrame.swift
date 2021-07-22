import SwiftUI

public struct FormFrame: ViewModifier {
	public init () {}
	public func body(content: Content) -> some View {
		content
			.padding([.leading, .trailing], 40)
	}
}
