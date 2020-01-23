import Foundation
import SwiftUI

struct WalkthroughContentState {
	let title: String
	let description: String
	let imageTitle: String
}

struct WalkthroughContentView: View {
	let state: WalkthroughContentState
	var body: some View {
		VStack {
			Image(state.imageTitle)
			Text(state.title)
			Text(state.description)
		}
	}
}
