import SwiftUI
import Model
import ComposableArchitecture

public enum JourneyProfileViewStyle {
	case short
	case long
}

public struct JourneyBaseView<Content: View>: View {
	let content: Content
	let appointment: Appointment?
	let style: JourneyProfileViewStyle

	init(appointment: Appointment?,
		 style: JourneyProfileViewStyle,
		 @ViewBuilder content: () -> Content) {
		self.appointment = appointment
		self.content = content()
		self.style = style
	}

	public var body: some View {
		VStack(spacing: 64) {
			JourneyProfileView(style: style,
							   viewState: JourneyProfileView.ViewState.init(appointment: appointment))
				.padding(.top, 32)
				.padding(.bottom, 32)
			content
		}
	}
}

struct JourneyBaseModifier: ViewModifier {
	let appointment: Appointment?
	let style: JourneyProfileViewStyle
	func body(content: Content) -> some View {
		JourneyBaseView(appointment: appointment, style: style, content: { content })
	}
}

public extension View {

	func journeyBase(_ appointment: Appointment?,
					 _ style: JourneyProfileViewStyle) -> some View {
		self.modifier(JourneyBaseModifier(appointment: appointment, style: style))
	}
}
