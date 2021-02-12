import SwiftUI
import Model
import ComposableArchitecture

public enum JourneyProfileViewStyle {
	case short
	case long
}

public struct JourneyBaseView<Content: View>: View {
	let content: Content
	let journey: Journey?
	let style: JourneyProfileViewStyle
	
	init(journey: Journey?,
		 style: JourneyProfileViewStyle,
		 @ViewBuilder content: () -> Content) {
		self.journey = journey
		self.content = content()
		self.style = style
	}
	
	public var body: some View {
		VStack(spacing: 64) {
			JourneyProfileView(style: style,
							   viewState: JourneyProfileView.ViewState.init(journey: journey))
				.padding(.top, 32)
				.padding(.bottom, 32)
			content
		}
	}
}

struct JourneyBaseModifier: ViewModifier {
	let journey: Journey?
	let style: JourneyProfileViewStyle
	func body(content: Content) -> some View {
		JourneyBaseView(journey: journey, style: style, content: { content })
	}
}

public extension View {
	
	func journeyBase(_ journey: Journey?,
					 _ style: JourneyProfileViewStyle) -> some View {
		self.modifier(JourneyBaseModifier(journey: journey, style: style))
	}
}
