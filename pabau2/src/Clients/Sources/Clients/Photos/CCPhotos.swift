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
	expandedPhotoReducer.optional.pullback(
		state: \CCPhotosState.expandedSection,
		action: /CCPhotosAction.expanded,
		environment: { $0 }),
	Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment>.init { state, action, _ in
		switch action {
		case .onSelectDate(let date):
			state.expandedSection = CCExpandedPhotosState(selectedDate: date, photos: state.childState.state)
		case .action:
			break
		case .expanded:
            break
		}
		return .none
	}
)

public struct CCPhotosState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[Date: [PhotoViewModel]]>
	var expandedSection: CCExpandedPhotosState?
}

public enum CCPhotosAction: Equatable {
	case onSelectDate(Date)
	case action(GotClientListAction<[Date: [PhotoViewModel]]>)
	case expanded(CCExpandedPhotosAction)
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>
	var body: some View {
		IfLetStore(store.scope(state: { $0.expandedSection },
							   action: { .expanded($0) }),
				   then: CCExpandedPhotos.init(store:),
				   else: groupedPhotos)
	}

	var groupedPhotos: some View {
		CCGroupedPhotos(store: store.scope(state: { $0.childState.state },
											action: { $0 }))
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
