import SwiftUI
import ComposableArchitecture
import Util
import Model
import PencilKit
import Overture

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
	struct PhotoElement: Identifiable, Equatable {
		var id: Int { index }
		let index: Int
		let photo: Photo
	}
	struct State: Equatable {
		let photos: IdentifiedArrayOf<PhotoElement>
		var editPhoto: EditPhotosState?
		public init (state: PhotosState) {
			let newOrdered = state.newPhotosOrder
				.map{ state.newPhotos[$0]!}
				.map(Photo.new)
			let savedOrdered = state.savedPhotosOrder
				.map { state.savedPhotos[$0]! }
				.map(Photo.saved)
			let res = newOrdered + savedOrdered
			let sorted = zip(res.indices, res)
				.map(PhotoElement.init(index:photo:))
				.sorted(by: their(\.photo.date))
			self.photos = IdentifiedArray.init(sorted)
			self.editPhoto = state.editPhoto
		}
	}

	var body: some View {
		WithViewStore(self.store.scope(
			state: State.init(state:))) { viewStore in
			OICollectionView(data: viewStore.state.photos,
											 layout: flowLayout) { photo in
												PhotoCell(photo: photo.photo)
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

struct PhotoCell: View {
	let photo: Photo
	var body: some View {
		Group {
			if extract(case: Photo.saved, from: photo) != nil {
				SavedPhotoCell(savedPhoto: extract(case: Photo.saved, from: photo)!)
			} else if extract(case: Photo.new, from: photo) != nil {
				NewPhotoCell(newPhoto: extract(case: Photo.new, from: photo)!)
			}
		}
		.frame(maxWidth: 150, maxHeight: 150)
		.padding()
	}
}

struct SavedPhotoCell: View {
	let savedPhoto: SavedPhoto
	var body: some View {
		Image(savedPhoto.url)
			.resizable()
			.aspectRatio(contentMode: .fit)
	}
}

struct NewPhotoCell: View {
	let newPhoto: NewPhoto
	var body: some View {
		Image(uiImage: newPhoto.image)
			.resizable()
			.aspectRatio(contentMode: .fit)
	}
}
