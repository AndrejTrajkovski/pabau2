import SwiftUI
import Model
import ComposableArchitecture
import Util

struct TopView<AvatarView: View, RightSide: View>: View {
	@ViewBuilder let avatarView: () -> AvatarView
	@ViewBuilder let rightSideContent: () -> RightSide
	let store: Store<Void, CheckInAction>
	var body: some View {
		ZStack {
			CheckInXButton(store: store)
				.padding()
				.exploding(.topLeading)
			Spacer()
			avatarView()
				.padding()
				.exploding(.top)
			Spacer()
			rightSideContent()
		}.frame(height: 168.0)
	}
}
