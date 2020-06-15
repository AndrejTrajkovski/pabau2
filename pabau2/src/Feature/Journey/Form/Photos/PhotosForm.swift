import SwiftUI
import ComposableArchitecture
import Util
import Model
import PencilKit
import Overture
import ASCollectionView

public struct PhotosState: Equatable {
	var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel> = []
	var selectedIds: [PhotoVariantId] = []
	var editPhoto: EditPhotosState?
}

let photosFormReducer: Reducer<PhotosState, PhotosFormAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .didSelectPhotoId(let id):
				state.selectedIds.append(id)
			case .didSelectEditPhotos:
				let selPhotos = state.photos.filter { state.selectedIds.contains($0.id) }
				state.editPhoto = EditPhotosState(selPhotos)
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
	case didSelectPhotoId(PhotoVariantId)
	case didSelectEditPhotos
	case editPhoto(EditPhotoAction)
}

struct PhotosForm: View {
	
	let store: Store<PhotosState, PhotosFormAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				EmptyView()
//				ASCollectionView {
//					MultiplePhotosSection(id: 0,
//																title: "",
//																store: <#T##Store<MultipleSelectPhotos, MultipleSelectPhotosAction>#>)
//				}.padding()
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
}

struct PhotoCell: View {
	let photo: PhotoViewModel
	let isSelected: Bool
	var body: some View {
		Group {
			if extract(case: Photo.saved, from: photo.basePhoto) != nil {
				SavedPhotoCell(savedPhoto: extract(case: Photo.saved, from: photo.basePhoto)!)
			} else if extract(case: Photo.new, from: photo.basePhoto) != nil {
				NewPhotoCell(newPhoto: extract(case: Photo.new, from: photo.basePhoto)!)
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
