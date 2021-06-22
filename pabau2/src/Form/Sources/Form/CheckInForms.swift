import SwiftUI
import Model
import ComposableArchitecture
import Util

public struct CheckInForms<FormsContent: View, AvatarView: View>: View {
	public init(store: Store<CheckInState, CheckInAction>, avatarView: @escaping () -> AvatarView, content: @escaping () -> FormsContent) {
		self.store = store
		self.avatarView = avatarView
		self.content = content
	}

	let store: Store<CheckInState, CheckInAction>
	let avatarView: () -> AvatarView
	let content: () -> FormsContent

	public var body: some View {
		print("CheckIn")
		return VStack (spacing: 0) {
			TopView(avatarView: avatarView,
						 rightSideContent: ribbonView,
						 store: store.stateless)
			VStack {
				StepSelector(store: store).frame(height: 80)
				Divider()
					.frame(maxWidth: .infinity)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
//				Forms(store: store,
//					  content: content)
				content()
					.padding([.bottom, .top], 32)
				Spacer()
			}
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
	
	@ViewBuilder
	func ribbonView() -> some View {
		RibbonView(store: store.actionless)
			.offset(x: -80, y: -60)
			.exploding(.topTrailing)
	}
}

struct Forms<FormsContent: View>: View {
	let store: Store<CheckInState, CheckInAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInAction>
	let content: () -> FormsContent

	struct State: Equatable {
		let selectedIdx: Int
		let formsCount: Int
		init(state: CheckInState) {
			self.selectedIdx = state.selectedIdx
			self.formsCount = state.stepForms.count
		}
	}

	init(store: Store<CheckInState, CheckInAction>,
		 @ViewBuilder content: @escaping () -> FormsContent) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
		self.content = content
	}

	//FIXME: Use PageView (or some implementation of UIPageViewController) or a UIScrollView UIViewRepresentable with isPagingEnabled = true. Maybe newer version of SwiftUI will support ScrollView + LazyHStack with paging. See latest SwiftUI docs. Currently, this implementation (with PagerView) is laggy
	var body: some View {
		PagerView(pageCount: viewStore.formsCount,
				  currentIndex: viewStore.binding(get: { $0.selectedIdx },
												  send: { .didSelectFlatFormIndex($0) }),
				  content: content
		)
	}
}

public struct FormFrame: ViewModifier {
	public init () {}
	public func body(content: Content) -> some View {
		content
			.padding([.leading, .trailing], 40)
	}
}
