import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public enum PhotoCompareAction: Equatable {
	case didChangeSelectedPhoto(id: PhotoVariantId)
    case didSelectShare
    case shareAction(PhotoShareSelectAction)
    case onBackCompare
    case sideBySideAction(PhotoSideBySideAction)
    case didSelectEdit
    case editPhoto(EditPhotoAction)
    case didTouchBackOnEditPhotos
}

enum PhotoCompareMode: Equatable {
	case single
	case double
}

struct PhotoCompareState: Equatable {
    public init(photos: [Date: [PhotoViewModel]],
				selectedDate: Date,
				selectedId: PhotoVariantId) {
		self.photos = photos
		let dateKP = \PhotoViewModel.basePhoto.date
		self.rightId = photos.values.flatMap { $0 }.sorted(by: dateKP).first!.id
		self.leftId = selectedId
    }

	var leftId: PhotoVariantId
	var rightId: PhotoVariantId
	var activeSide: ActiveSide = .left
	var photos: [Date: [PhotoViewModel]]
	var mode: PhotoCompareMode = .single
	var isTappedToZoom: Bool = false
	var dragOffset: CGSize = .zero
	var position: CGSize = .zero
	var currentMagnification: CGFloat = 1
	var pinchMagnification: CGFloat = 1
    var editPhotoState: EditPhotosState?
    var shareSelectState: PhotoShareSelectState?
    var isEditPhotosActive: Bool = false
}

let photoCompareReducer = Reducer.combine(
	photoShareSelectViewReducer.optional.pullback(
        state: \PhotoCompareState.shareSelectState,
        action: /PhotoCompareAction.shareAction,
        environment: { $0 }
    ),
    photoSideBySideReducer.pullback(
        state: \PhotoCompareState.self,
        action: /PhotoCompareAction.sideBySideAction,
        environment: { $0 }
    ),
    editPhotosReducer.optional.pullback(
        state: \PhotoCompareState.editPhotoState,
        action: /PhotoCompareAction.editPhoto,
        environment: { FormEnvironment(formAPI: $0.formAPI, userDefaults: $0.userDefaults, repository: $0.repository) }
    ),
    Reducer<PhotoCompareState, PhotoCompareAction, ClientsEnvironment> { state, action, _ in
		switch action {
		case .didChangeSelectedPhoto(let photoId):
			switch state.activeSide {
			case .left:
				state.leftId = photoId
			case .right:
				state.rightId = photoId
			}
        case .didSelectShare:
            state.shareSelectState = PhotoShareSelectState(photo: state.leftState.photo,
                                                           comparedPhoto: state.rightState.photo)
        case .didTouchBackOnEditPhotos:
            state.isEditPhotosActive = false
        case .didSelectEdit:
            var photosArray: IdentifiedArray<PhotoVariantId, PhotoViewModel> = []
            _ = state.photos.map { photos in
                    photosArray.append(contentsOf: photos.value)
            }
            state.editPhotoState = EditPhotosState(photosArray, currentPhoto: state.leftId)
            state.isEditPhotosActive = true
        case .shareAction(.backButton):
            state.shareSelectState = nil
        case .editPhoto(.goBack):
            state.isEditPhotosActive = false
        case .editPhoto(.singlePhotoEdit(.photoUploadResponse)):
            state.isEditPhotosActive = false
        default:
            break
        }
        return .none
    })

struct PhotoCompareView: View {
    let store: Store<PhotoCompareState, PhotoCompareAction>

    var body: some View {
        print("PhotoCompareView")
        return WithViewStore(self.store) { viewStore in
            NavigationLink.emptyHidden(
                viewStore.state.isEditPhotosActive,
                IfLetStore(self.store.scope(
                            state: { $0.editPhotoState }, action: { .editPhoto($0) }),
                           then: { EditPhotos(store: $0) }
                )
            )
            VStack {
                PhotoSideBySideView(store: store.scope(
                                        state: { $0 },
                                        action: { PhotoCompareAction.sideBySideAction($0)}
                                    )
                )

                Spacer()
                PhotosListTimelineView(store: self.store)

                NavigationLink
                    .emptyHidden(viewStore.shareSelectState != nil,
                                 IfLetStore(store.scope(state: { $0.shareSelectState },
                                                        action: { PhotoCompareAction.shareAction($0)}),
                                            then: { PhotoShareSelectView(store: $0) }
                                 )
                    )

            }
            .navigationBarTitle("Progress Gallery")
            .navigationBarItems(
                leading: HStack {
                    MyBackButton(text: Texts.back) {
                        viewStore.send(.onBackCompare)
                    }
                },
                trailing: HStack {
                    Button(action: {
                        viewStore.send(.sideBySideAction(.changeDisplayMode))
                    }) {
                        Image(viewStore.rightId != nil ? "ico-nav-compare" : "ico-nav-single")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                
                    Button("Edit") {
                        viewStore.send(.didSelectEdit)
                    }
                    
                    Button("Share") {
                        viewStore.send(.didSelectShare)
                    }
                })
        }
    }
}

extension PhotoCompareState {
	func getSelectedId() -> PhotoVariantId {
		switch activeSide {
		case .left:
			return leftId
		case .right:
			return rightId
		}
	}
}
