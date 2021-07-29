import SwiftUI
import ComposableArchitecture
import Util
import ASCollectionView
import CasePaths

public enum AftercareAction: Equatable {
	case aftercares(AftercareBoolAction)
	case recalls(AftercareBoolAction)
	case profile(SingleSelectImagesAction)
	case share(SingleSelectImagesAction)
}

public let aftercareReducer: Reducer<AftercareState, AftercareAction, Any> = (
	.combine(
        aftercareBoolSectionReducer.pullback(
			state: \AftercareState.aftercares,
			action: /AftercareAction.aftercares,
			environment: { $0 }
		),
        aftercareBoolSectionReducer.pullback(
            state: \AftercareState.recalls,
            action: /AftercareAction.recalls,
            environment: { $0 }
        ),
		singleSelectImagesReducer.pullback(
			state: \AftercareState.profile,
			action: /AftercareAction.profile,
			environment: { $0 }
		),
		singleSelectImagesReducer.pullback(
			state: \AftercareState.share,
			action: /AftercareAction.share,
			environment: { $0 })
	)
)

public struct AftercareForm: View {
	let store: Store<AftercareState, AftercareAction>
	@ObservedObject var viewStore: ViewStore<AftercareState, AftercareAction>
    
    public init(store: Store<AftercareState, AftercareAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

    public var body: some View {
		print("AftercareForm body")
		return ASCollectionView {
			AftercareImagesSection(
				id: 0,
				title: Texts.setProfilePhoto,
				store: self.store.scope(
					state: { $0.profile }, action: { .profile($0) })
				).section
			AftercareImagesSection(
				id: 1,
				title: Texts.sharePhoto,
				store: self.store.scope(
					state: { $0.share }, action: { .share($0) })
			).section
//			AftercareBoolSection(
//				id: 2,
//				title: Texts.sendAftercareQ,
//				desc: Texts.sendAftercareDesc,
//				options: self.viewStore.binding(
//					get: { $0.aftercares }, send: { .didUpdateAftercares($0) })
//			).section
//			AftercareBoolSection(
//				id: 3,
//				title: Texts.recallsQ,
//				desc: Texts.recallsDesc,
//				options: self.viewStore.binding(
//					get: { $0.recalls }, send: { .didUpdateRecalls($0) })
//			).section
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
