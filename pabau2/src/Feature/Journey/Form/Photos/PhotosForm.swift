import SwiftUI
import ComposableArchitecture
import Util
import Model
import PencilKit
import Overture
import ASCollectionView

public struct PhotosState: Equatable, Identifiable {
	public var id = UUID()
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
			case .didTouchBackOnEditPhotos:
				state.editPhoto = nil
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
	case didTouchBackOnEditPhotos
	case editPhoto(EditPhotoAction)
}

struct PhotosForm: View {
	let store: Store<PhotosState, PhotosFormAction>
	struct State: Equatable {
		let isEditPhotosActive: Bool
		init (state: PhotosState) {
			self.isEditPhotosActive = state.editPhoto != nil
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			Group {
				SelectPhotos(store: self.store.scope(
					state: { $0.selectPhotos },
					action: { .selectPhotos($0) }))
				NavigationLink.emptyHidden(
					viewStore.state.isEditPhotosActive,
					IfLetStore(self.store.scope(
						state: { $0.editPhoto }, action: { .editPhoto($0) }),
										 then: {
											EditPhotos(store: $0)
												.customBackButton {
													viewStore.send(.didTouchBackOnEditPhotos)
											}
						}
					)
				)
			}
		}.debug("Photos form")
	}
}

extension IdentifiedArray where Element == PhotoViewModel, ID == PhotoVariantId {
	static func wrap (_ savedPhotos: [[Int: SavedPhoto]]) -> Self {
		let res = savedPhotos
			.compactMap(Dictionary<PhotoVariantId, PhotoViewModel>.wrap)
			.compactMap(\.values.first)
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
		self.init(photos: IdentifiedArray.wrap(savedPhotos),
							selectedIds: [],
							editPhoto: nil)
	}
}
