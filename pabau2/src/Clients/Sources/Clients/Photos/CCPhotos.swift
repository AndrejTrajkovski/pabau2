import SwiftUI
import ComposableArchitecture
import Form
import Util

public let ccPhotosReducer: Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[Date: [PhotoViewModel]]>().reducer.pullback(
		state: \CCPhotosState.childState,
		action: /CCPhotosAction.action,
		environment: { $0 }
	)
	,
	.init { state, action, env in
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
		case .action(_):
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

public struct CCPhotosState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[Date: [PhotoViewModel]]>
	var selectedIds: [PhotoVariantId]
	var selectedDate: Date?
	var mode: CCPhotosViewMode = .grouped
}

public enum CCPhotosAction: Equatable {
	case switchMode(CCPhotosViewMode)
	case onSelectGroup(Date)
	case didTouchPhoto(PhotoVariantId)
	case action(GotClientListAction<[Date: [PhotoViewModel]]>)
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>
	var body: some View {
		WithViewStore(self.store.scope(state: { $0.mode }).actionless) { viewStore in
			Group {
				if viewStore.state == .grouped {
					CCGroupedPhotos(store:
						self.store.scope(state: { $0.childState.state },
														 action: { $0 })
					)
				} else if viewStore.state == .expanded {
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