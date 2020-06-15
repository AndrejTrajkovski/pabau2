import ComposableArchitecture
import ASCollectionView
import SwiftUI

public let multipleSelectPhotosReducer: Reducer<MultipleSelectPhotos, MultipleSelectPhotosAction, JourneyEnvironment> = .init {
	state, action, _ in
	switch action {
	case .didTouchPhotoId(let id):
		state.selectedIds.contains(id) ? state.selectedIds.removeAll(where: { $0 == id}) :
			state.selectedIds.append(id)
	}
	return .none
}

public struct MultipleSelectPhotos: Equatable {
	var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>
	var selectedIds: [PhotoVariantId]

	func isSelected(_ photo: PhotoViewModel) -> Bool {
		return self.selectedIds.contains(photo.id)
	}
}

public enum MultipleSelectPhotosAction: Equatable {
	case didTouchPhotoId(PhotoVariantId)
}

struct MultiplePhotosSection {
	let id: Int
	let title: String
	let store: Store<MultipleSelectPhotos, MultipleSelectPhotosAction>
	@ObservedObject var viewStore: ViewStore<MultipleSelectPhotos, MultipleSelectPhotosAction>

	public init(
		id: Int,
		title: String,
		store: Store<MultipleSelectPhotos, MultipleSelectPhotosAction>
		) {
		self.id = id
		self.store = store
		self.viewStore = ViewStore(store)
		self.title = title
	}

	func makeSection() -> ASCollectionViewSection<Int> {
		return ASCollectionViewSection(
			id: self.id,
			data: self.viewStore.state.photos,
			dataID: \.self.id) { photo, _ in
				return PhotoCell(photo: photo,
												 isSelected: self.viewStore.state.isSelected(photo))
					.onTapGesture {
						self.viewStore.send(.didTouchPhotoId(photo.id))
				}
		}
	}
}
