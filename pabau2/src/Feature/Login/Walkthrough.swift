import SwiftUI
import Combine
import PageControl
import ComposableArchitecture
import CasePaths
import Util
import Model

public struct Walkthrough: View {
	let state = makeState(titles: WalkthroughStatic.titles,
												descs: WalkthroughStatic.description,
												imageTitles: WalkthroughStatic.images)
	let store: Store<[LoginNavScreen], WalkthroughAction>
	@ObservedObject var viewStore: ViewStore<[LoginNavScreen], WalkthroughAction>
	public init (store: Store<[LoginNavScreen], WalkthroughAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: { $0 }, action: { $0 })
			.view
	}

	public var body: some View {
		VStack {
			PageView(state.map { WalkthroughContentView(state: $0)})
				.frame(maxHeight: 686.0)
			BigButton(text: Texts.signIn,
								btnTapAction: {
									self.viewStore.send(.signInTapped)
			})
		}
	}
}

public func walkthroughReducer(state: inout [LoginNavScreen], action: WalkthroughAction, environment: LoginEnvironment) -> [Effect<WalkthroughAction>] {
	switch action {
	case .signInTapped:
		state.append(.signInScreen)
		return []
	}
}

public enum WalkthroughAction: Equatable {
  case signInTapped
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
