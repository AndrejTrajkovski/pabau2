import SwiftUI
import ComposableArchitecture
import Util

struct CheckInXButton: View {

	let store: Store<Void, CheckInAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			XButton(onTouch: { viewStore.send(.onXTap) })
		}
	}
}
