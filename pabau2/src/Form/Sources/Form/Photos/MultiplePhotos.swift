import ComposableArchitecture
import ASCollectionView
import SwiftUI

public let selectPhotosReducer: Reducer<SelectPhotosState, SelectPhotosAction, Any> = .init {
	state, action, _ in
	switch action {
	case .didTouchPhotoId(let id):
		state.selectedIds.contains(id) ? state.selectedIds.removeAll(where: { $0 == id}) :
			state.selectedIds.append(id)
	}
	return .none
}

public struct SelectPhotosState: Equatable {
	public let photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>
	public var selectedIds: [PhotoVariantId]
	
	public init(
		photos: IdentifiedArrayOf<PhotoViewModel>,
		selectedIds: [PhotoVariantId]
	) {
		self.photos = IdentifiedArrayOf<PhotoViewModel>.init(photos)
		self.selectedIds = selectedIds
	}
	
	public init(
		photosArray: [PhotoViewModel],
		selectedIds: [PhotoVariantId]
	) {
		self.photos = IdentifiedArrayOf<PhotoViewModel>.init(photosArray)
		self.selectedIds = selectedIds
	}
	
	func isSelected(_ photo: PhotoViewModel) -> Bool {
		return self.selectedIds.contains(photo.id)
	}
}

public enum SelectPhotosAction: Equatable {
	case didTouchPhotoId(PhotoVariantId)
}

struct SelectPhotos: View {
	let store: Store<SelectPhotosState, SelectPhotosAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			ASCollectionView.init(
			data: viewStore.photos) { photo, _ in
				MultipleSelectPhotoCell(photo: photo,
                                        isSelected: viewStore.state.isSelected(photo))
					.onTapGesture {
						viewStore.send(.didTouchPhotoId(photo.id))
				}
			}.layout { sectionID in
				switch sectionID {
				case 0:
					return .grid(layoutMode: .fixedNumberOfColumns(4),
											 itemSpacing: 2.5,
											 lineSpacing: 2.5)
				default:
					fatalError()
				}
			}
		}
	}
}
