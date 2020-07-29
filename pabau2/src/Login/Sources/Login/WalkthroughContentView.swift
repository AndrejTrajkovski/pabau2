import Foundation
import SwiftUI

struct WalkthroughContentContent {
	let title: String
	let description: String
	let imageTitle: String
}

struct WalkthroughContentView: View {
	let state: WalkthroughContentContent
	var body: some View {
		VStack.init(spacing: 16.0) {
			Image(state.imageTitle)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(maxHeight: 383)
			Text(state.title)
				.font(.semibold24)
			Text(state.description)
				.font(.medium16)
				.multilineTextAlignment(.center)
		}
	}
}
