import SwiftUI
import ComposableArchitecture
import Util
import Model
import PencilKit

public struct PhotosState: Equatable {
	var newPhotosOrder: [UUID] = []
	var newPhotos: [UUID: NewPhoto] = [:]
	var savedPhotosOrder: [Int]
	var savedPhotos: [Int: SavedPhoto]
	var drawings: [Int: [PKDrawing]] = [:]
	var editPhoto: EditPhotosState?
	var isEmpty: Bool { savedPhotos.isEmpty && newPhotos.isEmpty }
}

let photosFormReducer: Reducer<PhotosState, PhotosFormAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .didSelectPhoto(let id):
				state.editPhoto =
					EditPhotosState(
						editingPhotoId: id,
						newPhotosOrder: state.newPhotosOrder,
						newPhotos: state.newPhotos,
						savedPhotosOrder: state.savedPhotosOrder,
						savedPhotos: state.savedPhotos
				)
			case .editPhoto: break
			}
			return .none
		},
		editPhotosReducer.optional.pullback(
			state: \PhotosState.editPhoto,
			action: /PhotosFormAction.editPhoto,
			environment: { $0 })
)

public enum PhotosFormAction: Equatable {
	case didSelectPhoto(Int)
	case editPhoto(EditPhotoAction)
}

struct PhotosForm: View {

	let store: Store<PhotosState, PhotosFormAction>
	
	struct State: Equatable {
		let photos: IdentifiedArray<Int, Photo>
	}
	
	var body: some View {
		WithViewStore(store) { viewStore in
			OICollectionView(data: viewStore.state.sortedPhotos,
											 layout: flowLayout) { photo in
												Image(photo.url)
												.resizable()
													.aspectRatio(contentMode: .fit)
													.frame(maxWidth: 150, maxHeight: 150)
													.padding()
													.onTapGesture {
														viewStore.send(.didSelectPhoto(photo.id))
												}
			}.padding()
			NavigationLink.emptyHidden(
				viewStore.state.editPhoto != nil,
				IfLetStore(self.store.scope(
					state: { $0.editPhoto }, action: { .editPhoto($0) }),
									 then: EditPhotos.init(store:)
				)
			)
		}
	}
}

extension PhotosForm.State {
	public init (state: PhotosState) {
		
	}
}
