import SwiftUI
import ComposableArchitecture

public let editPhotosListReducer = Reducer<EditPhotosState, EditPhotosListAction, Any>.init { state, action, _ in
	switch action {
	case .onSelect(let id):
		state.editingPhotoId = state.editingPhotoId == id ? nil : id
	case .onRemove(let id):
		state.photos.remove(id: id)
	}
	return .none
}

public enum EditPhotosListAction: Equatable {
	case onSelect(PhotoVariantId)
	case onRemove(PhotoVariantId)
}

struct EditPhotosList: View {
	let store: Store<EditPhotosState, EditPhotosListAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				Spacer()
				VStack {
					List {
						ForEach(viewStore.photos, id: \.id) { photo in
							SingleSelectPhotoCell(
								photo: photo,
								isSelected: viewStore.state.editingPhotoId == photo.id
							).onTapGesture {
								viewStore.send(.onSelect(photo.id))
							}
						}
					}
				}
			}
		}
	}
}
