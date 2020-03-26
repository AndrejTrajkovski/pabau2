import SwiftUI
import Model

public struct JourneyBaseView<Content: View>: View {
	let journey: Journey?
	let content: Content
	init(journey: Journey?,
			 @ViewBuilder content: () -> Content) {
		self.journey = journey
		self.content = content()
	}
	public var body: some View {
		Group {
			if journey != nil {
				VStack(spacing: 8) {
					makeProfileView(journey: journey!)
						.padding()
					content
				}
			} else {
				EmptyView()
			}
		}
	}
}

struct JourneyBaseModifier: ViewModifier {
	let journey: Journey?
	func body(content: Content) -> some View {
		JourneyBaseView(journey: journey, content: { content })
	}
}

public extension View {
	
	func journeyBase(_ journey: Journey?) -> some View {
		self.modifier(JourneyBaseModifier(journey: journey))
	}
//	func journeyBase<Content: View>(content: @escaping () -> Destination) -> some View {
//		self.modifier(ModaLinkViewModifier(isPresented: isPresented,
//																			 linkType: linkType,
//																			 destination: destination))
//	}
}
