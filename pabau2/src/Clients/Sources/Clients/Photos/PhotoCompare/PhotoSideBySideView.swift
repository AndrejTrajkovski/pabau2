import SwiftUI
import Form
import ComposableArchitecture

public enum ActiveSide: Equatable {
	case left
	case right
}

public enum PhotoSideBySideAction: Equatable {
    case changeDisplayMode
    case changeActiveSide(PhotoViewModel)
    case didChangeSelectedPhoto(PhotoVariantId)
    case changesAction(PhotoChangesAction)
}

let photoSideBySideReducer = Reducer.combine(
    Reducer<PhotoCompareState, PhotoSideBySideAction, ClientsEnvironment> { state, action, _ in
        switch action {
        case .changeDisplayMode:
            state.mode = state.mode == .single ? .double : .single
        case .changesAction(.onChangeDragOffset(let size)):
            break
        case .changesAction(.onSelect(let side)):
            state.activeSide = side
        case .changesAction(.onChangePinchMagnification(let value)):
            state.pinchMagnification = value
        case .changesAction(.onEndedMagnification(let value)):
            state.currentMagnification *= value
            if state.currentMagnification < 1 { state.currentMagnification = 1 }
            state.pinchMagnification = 1
        case .changesAction(.onTappedToZoom):
            state.isTappedToZoom.toggle()
            state.currentMagnification = state.isTappedToZoom ? 2 : 1
            if !state.isTappedToZoom {
                state.dragOffset = .zero
                state.position = .zero
			}
        default:
            break
        }
        return .none
    }
)

struct PhotoSideBySideView: View {

    var store: Store<PhotoCompareState, PhotoSideBySideAction>

    var body: some View {
		WithViewStore(self.store) { viewStore in
			HStack(spacing: 0) {
				PhotoDetailViewSecond(store: self.store.scope(state: { $0.leftState },
															  action: { PhotoSideBySideAction.changesAction($0)}
				)
				)
				if viewStore.mode == .double {
					PhotoDetailViewSecond(store: self.store.scope(state: { $0.rightState },
																  action: { PhotoSideBySideAction.changesAction($0)}
					)
					)
				}
			}
		}
	}
}

extension PhotoCompareState {
	
	var leftState: PhotoDetailState {
		get {
			PhotoDetailState(photo: photos.flatMap(\.value).first(where: { $0.id == leftId })!,
                             side: .left,
							 dragOffset: self.dragOffset,
							 position: self.position,
							 currentMagnification: self.currentMagnification,
							 pinchMagnification: self.pinchMagnification
			)
		}
		set {
			self.dragOffset = newValue.dragOffset
			self.position = newValue.position
			self.currentMagnification = newValue.currentMagnification
			self.pinchMagnification = newValue.pinchMagnification
		}
	}
	
	var rightState: PhotoDetailState {
		get {
			PhotoDetailState(photo: photos.flatMap(\.value).first(where: { $0.id == rightId })!,
                             side: .right,
							 dragOffset: self.dragOffset,
							 position: self.position,
							 currentMagnification: self.currentMagnification,
							 pinchMagnification: self.pinchMagnification
			)
		}
		set {
			self.dragOffset = newValue.dragOffset
			self.position = newValue.position
			self.currentMagnification = newValue.currentMagnification
			self.pinchMagnification = newValue.pinchMagnification
		}
	}
}
