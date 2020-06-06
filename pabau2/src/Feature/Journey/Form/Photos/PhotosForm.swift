import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct PhotosState: Equatable {
	var photosOrderedIds: [Int]
	var photos: [Int: JourneyPhotos]
	var sortedPhotos: [JourneyPhotos] {
		photosOrderedIds.map { photos[$0]! }
	}

	var editPhoto: EditPhotoState?
}

let photosFormReducer: Reducer<PhotosState, PhotosFormAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .didSelectPhoto(let id):
				state.editPhoto = EditPhotoState(editingPhotoId: id,
																				 photosOrderedIds: state.photosOrderedIds,
																				 photos: state.photos,
																				 drawings: [:])
			case .editPhoto: break
			}
			return .none
		},
		editPhotoReducer.optional.pullback(
			state: \PhotosState.editPhoto,
			action: /PhotosFormAction.editPhoto,
			environment: { $0 })
)


public enum PhotosFormAction {
	case didSelectPhoto(Int)
	case editPhoto(EditPhotoAction)
}

struct PhotosForm: View {

	let store: Store<PhotosState, PhotosFormAction>

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
									 then: EditPhoto.init(store:)
				)
			)
		}
	}
}
