import SwiftUI
import Combine
import ComposableArchitecture
import Util
import Model

public struct Walkthrough: View {
	let state = makeState(titles: WalkthroughStatic.titles,
						  descs: WalkthroughStatic.description,
						  imageTitles: WalkthroughStatic.images)
	let action: () -> Void
	@State var pageIdx: Int = 0

	public var body: some View {
		VStack {
			PageView(state.map { WalkthroughContentView(state: $0)},
					 $pageIdx)
				.frame(maxHeight: 686.0)
			PrimaryButton(Texts.signIn) {
				self.action()
			}.frame(minWidth: 304, maxWidth: 495)
		}
	}
}

public let walkthroughReducer = Reducer<[LoginNavScreen], WalkthroughAction, LoginEnvironment> { state, action, environment in
	switch action {
	case .signInTapped:
		state.append(.signInScreen)
		return .none
	case .onAppear:
		var userDefaults = environment.userDefaults
		userDefaults.hasSeenAppIntroduction = true
		return .none
	}
}

public enum WalkthroughAction: Equatable {
	case signInTapped
	case onAppear
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
