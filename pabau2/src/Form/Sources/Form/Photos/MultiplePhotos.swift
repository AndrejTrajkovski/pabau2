import ComposableArchitecture
import SwiftUI
import Model

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

    private let imagesColumns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid (
                    columns: imagesColumns,
                    alignment: .leading,
                    spacing: 16
                ){
                    ForEach(viewStore.photos) { photo in
                        MultipleSelectPhotoCell(photo: photo,
                                                isSelected: viewStore.state.isSelected(photo))
                            .onTapGesture {
                                viewStore.send(.didTouchPhotoId(photo.id))
                            }
                    }
                }
            }
        }
	}
}
