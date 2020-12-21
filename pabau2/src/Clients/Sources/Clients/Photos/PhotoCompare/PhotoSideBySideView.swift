import SwiftUI
import Form
import ComposableArchitecture

struct PhotoSideBySideState: Equatable {

    init(leftState: PhotoDetailState, rightState: PhotoDetailState) {
        self.leftState = leftState
        self.rightState = rightState
        self.activeSide = self.leftState
    }

    var displayMode: PhotoCompareMode = .single

    private var _activeSide: PhotoDetailState!
    var activeSide: PhotoDetailState {
        set {
            self._activeSide = newValue
        }
        get {
            return self._activeSide
        }
    }
    var leftState: PhotoDetailState!
    var rightState: PhotoDetailState!

    var isTappedToZoom: Bool = false

    var changesPhoto: MagnificationZoom = MagnificationZoom()

}

struct MagnificationZoom: Equatable {
    var dragOffset: CGSize = .zero
    var position: CGSize = .zero
    var currentMagnification: CGFloat = 1
    var pinchMagnification: CGFloat = 1
}

public enum PhotoSideBySideAction: Equatable {
    case changeDisplayMode
    case changeActiveSide(PhotoViewModel)
    case didChangeSelectedPhoto(PhotoVariantId)
    case changesAction(PhotoChangesAction)
}

var photoSideBySideReducer = Reducer.combine(
    changesPhotoReducer.pullback(
        state: \PhotoSideBySideState.leftState,
        action: /PhotoSideBySideAction.changesAction,
        environment: { $0 }
    ),
    changesPhotoReducer.pullback(
        state: \PhotoSideBySideState.rightState,
        action: /PhotoSideBySideAction.changesAction,
        environment: { $0 }
    ),
    Reducer<PhotoSideBySideState, PhotoSideBySideAction, ClientsEnvironment> { state, action, _ in
        switch action {
        case .changeDisplayMode:
            state.displayMode = state.displayMode == .single ? .multiple : .single
            break
        case .changesAction(.onChangeDragOffset(let size)):
            break
        case .changesAction(.onSelect):
            state.activeSide.isSelected = false
            state.activeSide = state.activeSide == state.leftState ? state.rightState : state.leftState
            state.activeSide.isSelected = true
        case .changesAction(.onChangePinchMagnification(let value)):
            state.changesPhoto.pinchMagnification = value
            state.leftState.changes = state.changesPhoto
            state.rightState.changes = state.changesPhoto
        case .changesAction(.onEndedMagnification(let value)):
            state.changesPhoto.currentMagnification *= value
            if state.changesPhoto.currentMagnification < 1 { state.changesPhoto.currentMagnification = 1 }
            state.changesPhoto.pinchMagnification = 1
            state.leftState.changes = state.changesPhoto
            state.rightState.changes = state.changesPhoto
            state.activeSide.changes = state.changesPhoto
        case .changesAction(.onTappedToZoom):
            state.isTappedToZoom.toggle()
            state.changesPhoto.currentMagnification = state.isTappedToZoom ? 2 : 1
            if !state.isTappedToZoom {
                state.changesPhoto.dragOffset = .zero
                state.changesPhoto.position = .zero
            }

            state.leftState = PhotoDetailState(photo: state.leftState.photo, changes: state.changesPhoto)
            state.leftState.changes = state.changesPhoto
            state.rightState.changes = state.changesPhoto
        default:
            break
        }
        return .none
    }
)

struct PhotoSideBySideView: View {

    var store: Store<PhotoSideBySideState, PhotoSideBySideAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in

            if viewStore.displayMode == .single {
                PhotoDetailViewSecond(store: self.store.scope(state: { $0.leftState },
                                                              action: { PhotoSideBySideAction.changesAction($0)}
                                    )
                )
            } else {
                HStack(spacing: 0) {
                    PhotoDetailViewSecond(store: self.store.scope(state: { $0.leftState },
                                                                  action: { PhotoSideBySideAction.changesAction($0)}
                                        )
                    )
                    PhotoDetailViewSecond(store: self.store.scope(state: { $0.rightState },
                                                                  action: { PhotoSideBySideAction.changesAction($0)}
                                        )
                    )
                }
            }

        }
    }
}
