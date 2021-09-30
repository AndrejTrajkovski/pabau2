import SwiftUI
import ComposableArchitecture
import ASCollectionView
import Form
import Model

let expandedPhotoReducer: Reducer<CCExpandedPhotosState, CCExpandedPhotosAction, ClientsEnvironment> = .combine(
    photoCompareReducer.optional().pullback(
        state: \CCExpandedPhotosState.photoCompare,
        action: /CCExpandedPhotosAction.photoCompare,
        environment: { $0 }
    ),
	.init { state, action, _ in
		switch action {
		case .didTouchPhoto(let id):
			state.photoCompare = PhotoCompareState(photos: state.photos, selectedDate: state.selectedDate, selectedId: id)
		case .photoCompare(.onBackCompare):
			state.photoCompare = nil
		case .photoCompare:
			break
		}
		return .none
	}
)

struct CCExpandedPhotosState: Equatable {
    let selectedDate: Date
	let photos: [Date: [PhotoViewModel]]
	var photoCompare: PhotoCompareState?
}

public enum CCExpandedPhotosAction: Equatable {
	case didTouchPhoto(PhotoVariantId)
	case photoCompare(PhotoCompareAction)
}

struct CCExpandedPhotos: View {
	let store: Store<CCExpandedPhotosState, CCExpandedPhotosAction>
	@ObservedObject var viewStore: ViewStore<State, CCExpandedPhotosAction>

	struct State: Equatable {
		let selectedDatePhotos: [PhotoViewModel]
		let isCompareActive: Bool
		let selectedDate: Date

		init(state: CCExpandedPhotosState) {
			self.selectedDate = state.selectedDate
			self.isCompareActive = state.photoCompare != nil
			self.selectedDatePhotos = state.photos[state.selectedDate] ?? []
		}
	}

	init(store: Store<CCExpandedPhotosState, CCExpandedPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

	var body: some View {
		Group {
			NavigationLink
				.emptyHidden(viewStore.isCompareActive,
							 IfLetStore(store.scope(state: { $0.photoCompare },
													action: { .photoCompare($0) }), then: {
														PhotoCompareView(store: $0)
															.navigationBarBackButtonHidden(true)
													})
				)
			ASCollectionView(sections: [selectedDateSection])
				.layout { _ in
					return .grid(layoutMode: .fixedNumberOfColumns(4),
								 itemSpacing: 16,
								 lineSpacing: 16)
				}
		}
	}

	var selectedDateSection: ASCollectionViewSection<Date> {
		ExpandedPhotosSection(date: viewStore.selectedDate,
                              photos: viewStore.selectedDatePhotos,
                              action: { viewStore.send(.didTouchPhoto($0)) }).section
	}
}

struct ExpandedPhotosSection {
	let date: Date
	let photos: [PhotoViewModel]
    let action: (PhotoVariantId) -> Void

	var section: ASCollectionViewSection<Date> {
		ASCollectionViewSection(
			id: date,
			data: self.photos) { photo, _ in
            PhotoCell(photo: photo, shouldShowThumbnail: true)
                .padding()
                .onTapGesture { action(photo.basePhoto.id) }
		}
		.sectionHeader {
			HStack {
				DateAndNumber(date: date, number: photos.count)
				Spacer()
			}.padding(.leading, 32)
		}
	}
}
