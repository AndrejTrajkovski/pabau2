import SwiftUI
import ComposableArchitecture
import ASCollectionView
import Form

struct CCExpandedPhotos: View {
	let store: Store<CCPhotosState, CCPhotosAction>
	@ObservedObject var viewStore: ViewStore<CCPhotosState, CCPhotosAction>

	init(store: Store<CCPhotosState, CCPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("CCExpandedPhotos")
		return ASCollectionView(sections: viewStore.state.selectedDate == nil ? sections : [selectedDateSection])
			.layout { sectionID in
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 16,
										 lineSpacing: 16)
		}
	}

	var selectedDateSection: ASCollectionViewSection<Date> {
			ExpandedPhotosSection(date: viewStore.state.selectedDate!,
														photos: viewStore.state.childState.state[viewStore.state.selectedDate!] ?? [],
														selectedIds: viewStore.state.selectedIds,
														viewStore: viewStore).section
	}

	var sections: [ASCollectionViewSection<Date>] {
		viewStore.state.childState.state.sorted(by: \.key).map {
			ExpandedPhotosSection(date: $0.key,
														photos: $0.value,
														selectedIds: viewStore.state.selectedIds,
														viewStore: viewStore)
				.section
		}
	}
}

struct ExpandedPhotosSection {
	let date: Date
	let photos: [PhotoViewModel]
	let selectedIds: [PhotoVariantId]
	let viewStore: ViewStore<CCPhotosState, CCPhotosAction>

	var section: ASCollectionViewSection<Date> {
		ASCollectionViewSection(
			id: date,
			data: self.photos) { photo, context in
				MultipleSelectPhotoCell(photo: photo,
																isSelected: self.selectedIds.contains(photo.id))
					.onTapGesture {
						self.viewStore.send(.didTouchPhoto(photo.id))
				}
		}
		.sectionHeader {
			HStack {
				DateAndNumber(date: date, number: photos.count)
				Spacer()
			}.padding(.leading, 32)
		}
	}
}
