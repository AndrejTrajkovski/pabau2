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
        state: \CCPhotosState.photoCompareState,
        action: /CCPhotosAction.actionCompare,
        environment: { $0 }),
	
	Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment>.init { state, action, env in
		switch action {
		case .onSelectGroup(let date):
			state.selectedDate = date
            state.displayMode = .compare
            state.isSelectedGroup = true
		case .switchMode(let mode):
			state.mode = mode
			state.selectedDate = nil
		case .didTouchPhoto(let id):
			print(id)
			state.selectedIds.contains(id) ? state.selectedIds.removeAll(where: { $0 == id}) :
				state.selectedIds.append(id)
		case .action(_):
			break
        case .onDisappearView:
            state.isSelectedGroup = false
        default :
            break
		}
		return .none
	}
).debug()

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
    var photosCompare: [PhotoViewModel] {
        guard let date = self.selectedDate else { return [] }
        return self.childState.state[date] ?? []
    }

}

extension CCPhotosState {
    var photoCompareState: PhotoCompareState {
        set {
        }
        get {
            PhotoCompareState(date: self.selectedDate, photos: photosCompare)
        }
    }
}

public enum CCPhotosAction: Equatable {
	case switchMode(CCPhotosViewMode)
	case onSelectGroup(Date)
	case didTouchPhoto(PhotoVariantId)
	case action(GotClientListAction<[Date: [PhotoViewModel]]>)
    
    case actionCompare(PhotoCompareAction)
    case onDisappearView
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>
	var body: some View {
        WithViewStore(self.store.scope(state: { $0 })) { viewStore in
            Group {
                
                if viewStore.displayMode == .compare {
                    NavigationLink
                        .emptyHidden(viewStore.isSelectedGroup,
                                     PhotoCompareView(store: Store(initialState: viewStore.photoCompareState,
                                                                   reducer: photoCompareReducer,
                                                                   environment: ClientsEnvironment(apiClient: ClientsMockAPI(),
                                                                                         userDefaults: StandardUDConfig())
                                                                )
                                     )
                                     .onDisappear(perform: {
                                        viewStore.send(.onDisappearView)
                                     })
                                                
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
