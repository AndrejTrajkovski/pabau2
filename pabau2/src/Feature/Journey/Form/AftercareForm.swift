import SwiftUI
import ComposableArchitecture

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
		ScrollView {
			VStack {
				SIngleSelectImagesField(
					store: self.store.scope(
						state: { $0.profile }, action: { .profile($0) })
				)
				SIngleSelectImagesField(
					store: self.store.scope(
						state: { $0.share }, action: { .share($0) })
				)
			}
		}
	}
}
