import SwiftUI
import PageControl
import ComposableArchitecture

public enum WalkthroughAction: Equatable {
  case signInTapped
	case loginAction(LoginAction)
}

public struct WalkthroughState {
	var isFinished: Bool
	var loginViewState: LoginViewState
}

public func walkthroughReducer(state: inout WalkthroughState,
															 action: WalkthroughAction) -> [Effect<WalkthroughAction>] {
	switch action {
	case .signInTapped:
		state.isFinished = true
		return []
	}
}

struct WalkthroughStatic {
	static let titles = [Texts.walkthrough1,
											 Texts.walkthrough2,
											 Texts.walkthrough3,
											 Texts.walkthrough4]
	static let description = [Texts.walkthroughDes1,
														Texts.walkthroughDes2,
														Texts.walkthroughDes3,
														Texts.walkthroughDes4]
	static let images = ["illu-walkthrough-1",
											 "illu-walkthrough-2",
											 "illu-walkthrough-3",
											 "illu-walkthrough-4"]
}

func makeState(titles: [String], descs: [String], imageTitles: [String]) -> [WalkthroughContentContent] {
	let zipped1 = zip(titles, descs)
	let zipped2 = zip(zipped1, imageTitles)
	return zipped2.map {
		return WalkthroughContentContent.init(title: $0.0, description: $0.1,
																				imageTitle: $1)
	}
}

struct WalkthroughContainerView: View {
	@ObservedObject var store: Store<WalkthroughState, WalkthroughAction>
	let state = makeState(titles: WalkthroughStatic.titles,
												descs: WalkthroughStatic.description,
												imageTitles: WalkthroughStatic.images)
	var body: some View {
		VStack(spacing: 50) {
			PageView(state.map { WalkthroughContentView(state: $0)})
				.frame(maxHeight: 686.0)
			BigButton(text: Texts.signIn,
								buttonTapAction: {
				self.store.send(.signInTapped)
			}).frame(minWidth: 320, maxWidth: 390)
			NavigationLink(destination: LoginView(store: self.store.view(value: <#T##(WalkthroughState) -> LocalValue#>, action: <#T##(LocalAction) -> WalkthroughAction#>)),
										 isActive: .constant(self.store.value.isFinished)) {
				EmptyView()
			}.hidden()
		}
	}
}
