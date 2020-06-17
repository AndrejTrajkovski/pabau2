import SwiftUI
import ComposableArchitecture
import Util
import ASCollectionView
import CasePaths

public enum AftercareAction {
	case didUpdateAftercares([AftercareOption])
	case didUpdateRecalls([AftercareOption])
	case profile(SingleSelectImagesAction)
	case share(SingleSelectImagesAction)
}

public let aftercareReducer: Reducer<Aftercare, AftercareAction, Any> = (
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .didUpdateAftercares(let options):
				state.aftercares = options
			case .didUpdateRecalls(let recalls):
				state.recalls = recalls
			default:
				break
			}
			return .none
		},
//		aftercareOptionReducer.forEach(
//			state: \Aftercare.aftercares,
//			action: /AftercareAction.aftercares..AftercareBoolAction.indexedToggle,
//			environment: { $0 }
//		),
//		aftercareOptionReducer.forEach(
//			state: \Aftercare.recalls,
//			action: /AftercareAction.recalls..AftercareBoolAction.indexedToggle,
//			environment: { $0 }
//		),
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
		print("AftercareForm body")
		return ASCollectionView {
//			AftercareImagesSection(
//				id: 0,
//				title: Texts.setProfilePhoto,
//				store: self.store.scope(
//					state: { $0.profile }, action: { .profile($0) })
//				).section
//			AftercareImagesSection(
//				id: 1,
//				title: Texts.sharePhoto,
//				store: self.store.scope(
//					state: { $0.share }, action: { .share($0) })
//			).section
			AftercareBoolSection(
				id: 2,
				title: Texts.sendAftercareQ,
				desc: Texts.sendAftercareDesc,
				options: self.viewStore.binding(
					get: { $0.aftercares }, send: { .didUpdateAftercares($0) })
			).section
			AftercareBoolSection(
				id: 3,
				title: Texts.recallsQ,
				desc: Texts.recallsDesc,
				options: self.viewStore.binding(
					get: { $0.recalls }, send: { .didUpdateRecalls($0) })
			).section
		}.layout { sectionID in
			switch sectionID {
			case 0, 1:
				// Here we use one of the provided convenience layouts
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 2.5,
										 lineSpacing: 2.5)
			case 2, 3:
				return
					.list(itemSize: .absolute(60))
			default:
				fatalError()
			}
		}
		.scrollIndicatorsEnabled(horizontal: false, vertical: false)
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarBackButtonHidden(true)
		.navigationBarHidden(true)
	}
}

struct AftercareTitle: View {
	let title: String
	init (_ title: String) {
		self.title = title
	}
	var body: some View {
		Text(title)
			.font(.bold24)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding([.top, .bottom], 16)
	}
}
