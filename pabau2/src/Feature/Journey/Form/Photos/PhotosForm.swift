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
	var selectPhotos: SelectPhotosState {
		get { SelectPhotosState(photos: photos, selectedIds: selectedIds) }
		set { self.selectedIds = newValue.selectedIds}
	}
	func selectedPhotos() -> IdentifiedArray<PhotoVariantId, PhotoViewModel> {
		photos.filter { selectedIds.contains($0.id) }
	}
}

let photosFormReducer: Reducer<PhotosState, PhotosFormAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .didSelectEditPhotos:
				let selPhotos = state.photos.filter { state.selectedIds.contains($0.id) }
				state.editPhoto = EditPhotosState(selPhotos)
			case .editPhoto, .selectPhotos: break
			}
			return .none
		},
		editPhotosReducer.optional.pullback(
			state: \PhotosState.editPhoto,
			action: /PhotosFormAction.editPhoto,
			environment: { $0 }),
		selectPhotosReducer.pullback(
			state: \PhotosState.selectPhotos,
			action: /PhotosFormAction.selectPhotos,
			environment: { $0 })
)

public enum PhotosFormAction: Equatable {
	case selectPhotos(SelectPhotosAction)
	case didSelectEditPhotos
	case editPhoto(EditPhotoAction)
}

struct PhotosForm: View {
	let store: Store<PhotosState, PhotosFormAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				SelectPhotos(store: self.store.scope(
					state: { $0.selectPhotos },
					action: { .selectPhotos($0) }))
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
		ZStack(alignment: .bottomTrailing) {
			Group {
				if extract(case: Photo.saved, from: photo.basePhoto) != nil {
					SavedPhotoCell(savedPhoto: extract(case: Photo.saved, from: photo.basePhoto)!)
				} else if extract(case: Photo.new, from: photo.basePhoto) != nil {
					NewPhotoCell(newPhoto: extract(case: Photo.new, from: photo.basePhoto)!)
				}
			}
			if isSelected {
				ZStack {
					Circle()
						.fill(Color.blue)
					Circle()
						.strokeBorder(Color.white, lineWidth: 2)
					Image(systemName: "checkmark")
						.font(.system(size: 10, weight: .bold))
						.foregroundColor(.white)
				}
				.frame(width: 20, height: 20)
				.padding(10)
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

extension IdentifiedArray where Element == PhotoViewModel, ID == PhotoVariantId {
	static func wrap (_ savedPhotos: [[Int: SavedPhoto]]) -> Self {
		let res = savedPhotos.compactMap(Dictionary<PhotoVariantId, PhotoViewModel>.wrap).compactMap(\.values.first)
		return IdentifiedArray(res)
	}
}

extension Dictionary where Key == PhotoVariantId, Value == PhotoViewModel {
	static func wrap(_ savedPhotoDict: [Int: SavedPhoto]) -> Self? {
		guard savedPhotoDict.count == 1 else { return nil }
		return [PhotoVariantId.saved(savedPhotoDict.keys.first!):
			PhotoViewModel.init(savedPhotoDict.values.first!) ]
	}
}

extension PhotosState {
	init(_ savedPhotos: [[Int: SavedPhoto]]) {
		self.init(photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>.wrap(savedPhotos)
			, selectedIds: [], editPhoto: nil)
	}
}
