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

    photoCompareReducer.pullback(
        state: \CCPhotosState.photoCompare,
        action: /CCPhotosAction.photoCompare,
        environment: { $0 }),

	Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment>.init { state, action, _ in
		switch action {
		case .onSelectGroup(let date):
			state.selectedDate = date
            state.mode = .expanded
		case .switchMode(let mode):
			state.mode = mode
			state.selectedDate = nil
		case .didTouchPhoto(let id):
			print(id)
			state.selectedIds.contains(id) ? state.selectedIds.removeAll(where: { $0 == id}) :
				state.selectedIds.append(id)
            state.isSelectedGroup = true
            state.displayMode = .compare
            state.photoCompare = PhotoCompareState(photos: state.photos, selectedId: state.selectedIds.first)
		case .action:
			break
        case .photoCompare(.onBackCompare):
            state.isSelectedGroup = false
            state.selectedDate = nil
            state.selectedIds.removeAll()
            state.mode = .grouped
            break
        default :
            break
		}
		return .none
	}
)

public enum CCPhotosViewMode: Int, Equatable, CaseIterable, CustomStringConvertible {
	case grouped
	case expanded

	public var description: String {
		switch self {
		case .grouped:
			return "Grouped"
		case .expanded:
			return "Expanded"
		}
	}
}

public enum CCPhotosViewDisplayMode: Int, Equatable {
    case photos
    case compare
}

public struct CCPhotosState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[Date: [PhotoViewModel]]>
	var selectedIds: [PhotoVariantId]
	var selectedDate: Date?
	var mode: CCPhotosViewMode = .grouped
    var displayMode: CCPhotosViewDisplayMode = .photos

    var isSelectedGroup: Bool = false
    var photos: [PhotoViewModel] {
        guard let date = self.selectedDate else { return [] }

        return childState.state.values.reduce([], { $0 + $1 })
    }

    init(childState: ClientCardChildState<[Date: [PhotoViewModel]]>, selectedIds: [PhotoVariantId]) {
        self.childState = childState
        self.selectedIds = selectedIds

        self.photoCompare = PhotoCompareState(photos: [], selectedId: selectedIds.first)
    }

    var photoCompare: PhotoCompareState
}

public enum CCPhotosAction: Equatable {
	case switchMode(CCPhotosViewMode)
	case onSelectGroup(Date)
	case didTouchPhoto(PhotoVariantId)
	case action(GotClientListAction<[Date: [PhotoViewModel]]>)

    case photoCompare(PhotoCompareAction)
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>

	var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if viewStore.displayMode == .compare {
                    NavigationLink
                        .emptyHidden(viewStore.isSelectedGroup,
                                     PhotoCompareView(store: store.scope(state: { $0.photoCompare },
                                                                         action: { .photoCompare($0) }))
                                    .navigationBarBackButtonHidden(true)
                    )
                }

                if viewStore.mode == .grouped {
                    CCGroupedPhotos(store: self.store.scope(state: { $0.childState.state },
                                                            action: { $0 }))

                } else if viewStore.mode == .expanded {

                    CCExpandedPhotos(store:
                        self.store.scope(state: { $0 },
                        action: { $0 })
                    )

                } else {
                    EmptyView()
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
