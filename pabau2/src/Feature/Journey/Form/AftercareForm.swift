import SwiftUI
import ComposableArchitecture
import Util

public enum AftercareAction {
	case aftercares(Indexed<ToggleAction>)
	case recalls(Indexed<ToggleAction>)
	case profile(SingleSelectImagesAction)
	case share(SingleSelectImagesAction)
}

public let aftercareReducer: Reducer<Aftercare, AftercareAction, Any> = (
	.combine(
		aftercareOptionReducer.forEach(
			state: \Aftercare.aftercares,
			action: /AftercareAction.aftercares,
			environment: { $0 }
		),
		recallReducer.forEach(
			state: \Aftercare.recalls,
			action: /AftercareAction.recalls,
			environment: { $0 }
		),
		singleSelectImagesReducer.pullback(
			state: \Aftercare.profile,
			action: /AftercareAction.profile,
			environment: { $0 }
		),
		singleSelectImagesReducer.pullback(
			state: \Aftercare.share,
			action: /AftercareAction.share,
			environment: { $0 })
	)
)

struct AftercareForm: View {

	let store: Store<Aftercare, AftercareAction>
	@ObservedObject var viewStore: ViewStore<Aftercare, AftercareAction>
	init(store: Store<Aftercare, AftercareAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		GeometryReader { geo in
			ScrollView (.vertical) {
				VStack {
					AftercareImageSection(
						Texts.setProfilePhoto,
						self.store.scope(
							state: { $0.profile }, action: { .profile($0) })
					)
						.background(GeometryReader { proxy in
							Color.clear.preference(key: HeightKey.self, value: proxy.size.width)
						})
					AftercareImageSection(
						Texts.sharePhoto,
						self.store.scope(
							state: { $0.share }, action: { .share($0) })
					)
					ForEachStore(self.store.scope(
						state: { $0.aftercares },
						action: { AftercareAction.aftercares(Indexed($0, $1)) }
					),
						content: AftercareOptionCell.init(store:)
					)
				}.frame(width: geo.size.width, height: 1000)
			}
		}
	}
}

struct AftercareSection<Content: View>: View {
	let title: String
	let content: () -> Content
	init (title: String, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.content = content
	}
	
	var body: some View {
		VStack {
			Text(title).font(.title)
			content()
		}
	}
}

//struct AftercareBooleanSection: View {
//	let title: String
//	let store: Store<[AftercareOption], [ToggleAction]>
//
//	var body: some View {
//		ForEachStore(self.store) { viewStore in
//
//		}
//	}
//}

struct AftercareImageSection: View {
	let title: String
	let store: Store<SingleSelectImages, SingleSelectImagesAction>

	init (_ title: String, _ store: Store<SingleSelectImages, SingleSelectImagesAction>) {
		self.title = title
		self.store = store
	}

	var body: some View {
		AftercareSection(title: title) {
			SIngleSelectImagesField(
				store: self.store.scope(
					state: { $0 }, action: { $0 })
			)
		}
	}
}


struct HeightKey: PreferenceKey {
	static let defaultValue: CGFloat? = nil static func reduce(value: inout CGFloat?,
																														 nextValue: () -> CGFloat?) {
		value = value ?? nextValue() }
}
