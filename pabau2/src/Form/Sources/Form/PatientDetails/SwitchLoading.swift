import SwiftUI
import ComposableArchitecture
import SharedComponents
import Util

struct SwitchLoading: View {
	
	let store: Store<LoadingState, ErrorViewAction>
	
	var body: some View {
		SwitchStore(store) {
			CaseLet(state: /LoadingState.gotError, action: { $0 },
					then: ErrorRetry.init(store:))
			CaseLet(state: /LoadingState.loading, action: { $0 },
					then: { (store: Store<Void, ErrorViewAction>) in
						LoadingSpinner(title: "Loading...")
					}
			)
			CaseLet(state: /LoadingState.initial, action: { $0 },
					then: { (store: Store<Void, ErrorViewAction>) in
						LoadingSpinner(title: "Loading")
					}
			)
		}
	}
}
