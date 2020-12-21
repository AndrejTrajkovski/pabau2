import SwiftUI
import ComposableArchitecture
import Form
import Util
import Model

public let ccPhotosReducer: Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[Date: [PhotoViewModel]]>().reducer.pullback(
		state: \CCPhotosState.childState,
		action: /CCPhotosAction.action,
		environment: { $0 }
	),

	photoCompareReducer.optional.pullback(
        state: \CCPhotosState.photoCompare,
        action: /CCPhotosAction.photoCompare,
        environment: { $0 }),

	Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment>.init { state, action, _ in
		switch action {
		case .onSelectDate(let date):
			state.selectedDate = date
		case .didTouchPhoto(let id):
			state.photoCompare = PhotoCompareState(photos: childState.state, selectedId: id)
		case .action:
			break
        case .photoCompare(.onBackCompare):
            state.photoCompare = nil
            break
        default :
            break
		}
		return .none
	}
)

public struct CCPhotosState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[Date: [PhotoViewModel]]>
	var selectedDate: Date?
    var photoCompare: PhotoCompareState?
}

public enum CCPhotosAction: Equatable {
	case onSelectDate(Date)
	case didTouchPhoto(PhotoVariantId)
	case action(GotClientListAction<[Date: [PhotoViewModel]]>)

    case photoCompare(PhotoCompareAction)
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>
	
	var body: some View {
		WithViewStore(self.store) { viewStore in
			Group {
				NavigationLink
					.emptyHidden(viewStore.photoCompare != nil,
								 IfLetStore(store.scope(state: { $0.photoCompare },
														action: { .photoCompare($0) }), then: {
															PhotoCompareView(store: $0)
																.navigationBarBackButtonHidden(true)
														})
					)
				if viewStore.selectedDate != nil {
					CCExpandedPhotos(store:
										self.store.scope(state: { $0 },
														 action: { $0 })
					)
				} else {
					CCGroupedPhotos(store: self.store.scope(state: { $0.childState.state },
															action: { $0 }))
				}
			}
		}.debug("CCPhotos")
	}
}

extension CCPhotosAction: ClientCardChildParentAction {
	var action: GotClientListAction<[Date: [PhotoViewModel]]>? {
		get {
			if case .action(let app) = self {
				return app
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue {
				self = .action(newValue)
			}
		}
	}
}
