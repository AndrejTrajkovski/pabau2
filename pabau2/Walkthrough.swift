import Foundation
import SwiftUI

struct WalkthroughState {
	let text: String
	let imageTitle: String
}

struct WalkthroughContentView: View {
	let state: WalkthroughState
	var body: some View {
		VStack {
			Image(state.imageTitle)
			Text(state.text)
		}
	}
}
